//
//  TransferViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwifterSwift
import cybex_ios_core_cpp

class TransferViewController: BaseViewController {

    @IBOutlet weak var transferView: TransferView!
    var accountName: String = ""
    var selectedVestingTimeIndex = 0

    var coordinator: (TransferCoordinatorProtocol & TransferStateManagerProtocol)?
    var switchVestingObservable = BehaviorSubject(value: false)

    var transfering: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        self.coordinator?.calculateFee(AssetConfiguration.CybexAsset.CYB.id, memo: self.transferView.memoView.textView.text)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.transferView.accountView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func configureObserveState() {
        self.transferView.transferButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }

            self.clickTransferAction()
        }).disposed(by: disposeBag)

        let vestingValid = Observable.combineLatest(switchVestingObservable.asObserver(),
            self.transferView.postVestingView.timeTextFiled.rx.text.orEmpty,
                                                    self.transferView.postVestingView.pubkeyTextview.rx.text.orEmpty).map { (status, time, pubkey) -> Bool in
                                                        if status {
                                                            return time.count > 0 && pubkey.count > 0
                                                        }
                                                        else {
                                                            return true
                                                        }
        }

        //按钮状态监听
        Observable.combineLatest(self.coordinator!.state.accountValid.asObservable(),
                                 self.coordinator!.state.amountValid.asObservable(),
                                 vestingValid).subscribe(onNext: {[weak self] (accountValid, amountValid, vestingValid) in
                                    guard let self = self else { return }

                                    var enable = false
                                    
                                    if let _ = self.coordinator?.state.balance.value, let transferAmount = self.coordinator?.state.amount.value.decimal(), vestingValid {

                                        if accountValid == .validSuccessed && amountValid && transferAmount > 0 {
                                            enable = true
                                        }
                                    }

                                    self.transferView.buttonIsEnable = enable

                                    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //账户监听
        self.coordinator!.state.accountValid.asObservable().subscribe(onNext: {[weak self] (status) in
            guard let self = self else { return }
            self.transferView.accountValidStatus = status
            if status == .validFailed && !(self.coordinator?.state.account.value.isEmpty)!, self.transferView.accountView.textField.text!.count != 0 {
                self.transferView.accountView.loadingState = .fail
//                self.showToastBox(false, message: R.string.localizable.transfer_account_unexist.key.localized())
            } else {
                self.transferView.accountView.loadingState = .success
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //余额监听
        self.coordinator!.state.amountValid.asObservable().subscribe(onNext: {[weak self] (result) in
            guard let self = self else { return }
            if !result, ((self.coordinator?.state.fee.value) != nil), self.coordinator?.state.balance.value != nil, self.transferView.balance.count != 0 {
                self.showToastBox(false, message: R.string.localizable.transfer_balance_unenough.key.localized())
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //币种及余额监听
        self.coordinator!.state.balance.asObservable().subscribe(onNext: {[weak self] (balance) in
            guard let self = self else { return }
            if let balance = balance, let balanceInfo = appData.assetInfo[balance.assetType] {
                if let info = appData.assetInfo[balance.assetType] {
                    self.transferView.crypto = info.symbol.filterSystemPrefix
                    self.transferView.precision = info.precision
                    let realBalance = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance)
                    let transferBalanceKey = R.string.localizable.transfer_balance.key.localized()
                    self.transferView.balance = transferBalanceKey + realBalance.formatCurrency(digitNum: info.precision) + " " + balanceInfo.symbol.filterSystemPrefix
                    self.transferView.quantityView.textField.text = ""
                    self.coordinator?.setAmount("")
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //手续费监听
        self.coordinator!.state.fee.asObservable().subscribe(onNext: {[weak self] (result) in
            guard let self = self else { return }
            if let data = result, let feeInfo = appData.assetInfo[data.assetId] {
                let fee = data
                self.transferView.fee = fee.amount.formatCurrency(digitNum: feeInfo.precision) + " " + feeInfo.symbol.filterSystemPrefix
                self.coordinator?.validAmount()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.transferView.accountView.unitLabel.rx.tapGesture().when(.recognized).asObservable().subscribe(onNext: { [weak self](_) in
            guard let self = self else { return }
            self.coordinator?.chooseOrAddAddress()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        self.coordinator?.state.account.asObservable().skip(1).subscribe(onNext: { [weak self](account) in
            guard let self = self else { return }
            self.transferView.accountView.textField.text = account
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.coordinator?.state.toAccount.asObservable().skip(1).subscribe(onNext: { [weak self](account) in
            guard let self = self else { return }

            self.checkIfShowPubKey(account)

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.switchVestingObservable.subscribe(onNext: {[weak self] (status) in
            guard let self = self else { return }

            if !status {
                self.transferView.postVestingView.hiddenPubkey()
            }
            else {
                self.checkIfShowPubKey(self.coordinator?.state.toAccount.value)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    func checkIfShowPubKey(_ account: Account?) {
        if let toaccount = account  {
            if toaccount.activePubKeys.count > 1 {
                if try! self.switchVestingObservable.value() {
                    self.transferView.postVestingView.showPubkey()
                }
                self.transferView.contentView.updateContentSize()
                self.transferView.updateContentSize()
            }
            else {
                let pubkey = toaccount.activePubKeys[0]
                self.transferView.postVestingView.setPubkey(pubkey)
                self.transferView.contentView.updateContentSize()
                self.transferView.updateContentSize()
            }

        }
    }

    func setupUI() {
        self.title = R.string.localizable.transfer_title.key.localized()
        self.configRightNavButton(R.image.ic_records_24_px())
        self.configLeftNavigationButton(nil)
    }

    func clickTransferAction() {
        if transfering {
            return
        }

        transfering = true
        self.view.endEditing(true)

        SwifterSwift.delay(milliseconds: 300) {
            self.transfering = false

            if self.transferView.accountView.loadingState != .success ||
                self.coordinator!.state.accountValid.value != AccountValidStatus.validSuccessed {
                self.transferView.accountView.loadingState = .normal
                return
            }
            if !self.transferView.buttonIsEnable {
                return
            }

            self.transferComfirm()
        }
    }

    func transferComfirm() {
        if let account = self.transferView.accountView.textField.text,
            let balance = self.coordinator?.state.balance.value,
            let amount = self.transferView.quantityView.textField.text,
            let memo = self.transferView.memoView.textView.text,
            let fee = self.coordinator?.state.fee.value {
            if let feeInfo = appData.assetInfo[fee.assetId] {
                let data = UIHelper.getTransferInfo(account,
                                           quanitity: amount + " " + (appData.assetInfo[balance.assetType]?.symbol.filterSystemPrefix)!,
                                           fee: fee.amount.formatCurrency(digitNum: feeInfo.precision) + " " + feeInfo.symbol.filterSystemPrefix,
                                           memo: memo.replacingOccurrences(of: "\n", with: "...\n"))
                if memo.isEmpty, UserManager.shared.checkExistCloudPassword() {
                    let titleLocali = UserManager.shared.unlockType == .cloudPassword ? R.string.localizable.enotes_use_type_0.key : R.string.localizable.enotes_use_type_1.key
                    showConfirm(R.string.localizable.transfer_ensure_title.key.localized(), attributes: data, rightTitleLocali: titleLocali, tag: titleLocali, setup: nil)
                } else {
                    showConfirm(R.string.localizable.transfer_ensure_title.key.localized(), attributes: data)
                }
            }
        }
    }

    func transfer() {
        self.startLoading()
        let timeAmountStr = self.transferView.postVestingView.timeTextFiled.text ?? ""

        let timeAmount: UInt64 = timeAmountStr.isEmpty ? 0 : UInt64(timeAmountStr) ?? 0
        let timeUnit: [UInt64] = [1, 60, 3600, 3600 * 24]

        self.coordinator?.transfer(timeUnit[self.selectedVestingTimeIndex] * timeAmount,
                                   toPubKey: self.transferView.postVestingView.pubkeyTextview.text ?? "", callback: {[weak self] (data) in
                                    guard let self = self else { return }

                                    Log.print(data)
                                    self.endLoading()
                                    ShowToastManager.shared.hide()
                                    if self.isVisible {
                                        if String(describing: data) == "<null>"{
                                            if AddressManager.shared.containAddressOfTransfer(self.coordinator!.state.account.value).0 == false {
                                                self.showConfirmImage(
                                                    R.image.icCheckCircleGreen.name,
                                                    title: R.string.localizable.transfer_success_title.key.localized(),
                                                    content: R.string.localizable.transfer_success_content.key.localized())
                                                self.accountName = self.coordinator!.state.account.value
                                            } else {
                                                self.showToastBox(true, message: R.string.localizable.transfer_successed.key.localized())
                                                self.coordinator?.reopenAction()
                                            }
                                        } else {
                                            self.showToastBox(false, message: R.string.localizable.transfer_failed.key.localized())
                                        }
                                    }
        })
    }

    override func rightAction(_ sender: UIButton) {
        self.coordinator?.pushToRecordVC()
    }
}

extension TransferViewController {
    override func passwordDetecting() {
        self.startLoading()
    }

    override func passwordPassed(_ passed: Bool) {
        self.endLoading()
        if passed {
            transfer()
        } else {
            showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }

    override func returnEnsureActionWithData(_ tag: String) {
        if tag == R.string.localizable.enotes_feature_hint.key.localized() { // 添加云账户
            pushCloudPasswordViewController(nil)
            return
        }
        if UserManager.shared.loginType == .nfc, UserManager.shared.unlockType == .nfc {
            if #available(iOS 11.0, *) {
                if !self.coordinator!.state.memo.value.isEmpty {
                    if !UserManager.shared.checkExistCloudPassword() {
                        showPureContentConfirm(R.string.localizable.confirm_hint_title.key.localized(), ensureButtonLocali: R.string.localizable.enotes_feature_add.key, content: R.string.localizable.enotes_feature_hint.key, tag: R.string.localizable.enotes_feature_hint.key.localized())
                    } else {
                        showPasswordBox(R.string.localizable.enotes_unlock_type_1.key.localized(), hintKey: R.string.localizable.enotes_transfer_memo_hint.key, middleType: .normal)
                    }
                } else {
                    NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                        BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)
                        self.transfer()
                    }
                    NFCManager.shared.start()
                }
            }
        } else if UserManager.shared.isLocked {
            showPasswordBox()
        } else {
            transfer()
        }
    }

    override func didClickedRightAction(_ tag: String) {
        if tag == R.string.localizable.enotes_use_type_0.key { //enotes
            if #available(iOS 11.0, *) {
                NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                    BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)
                    self.transfer()
                }
                NFCManager.shared.start()
            } 
        } else {
            showPasswordBox()
        }
    }

    override func returnEnsureImageAction() {

        let transferAddress = TransferAddress(id: AddressManager.shared.getUUID(), name: "", address: self.accountName)
        self.coordinator?.reopenAction()
        self.coordinator?.openAddTransferAddress(transferAddress)
    }

    override func cancelImageAction(_ sender: CybexTextView) {
        if sender.title.isHidden == true {
            self.coordinator?.reopenAction()
        }
    }

    @objc func selectCrypto(_ data: [String: Any]) {
        self.coordinator?.showPicker()
    }

    @objc func account(_ data: [String: Any]) {
        if let text = data["content"] as? String {
            self.coordinator?.dispatchAccountAction(AccountValidStatus.unValided)
            self.transferView.postVestingView.clearPubkey()
            self.transferView.postVestingView.hiddenPubkey()
            self.transferView.contentView.updateContentSize()
            self.transferView.updateContentSize()
            if text.count != 0 {
                self.coordinator?.setAccount(text)
            } else {
                self.transferView.accountView.loadingState = .normal
            }
        }
    }

    @objc func amount(_ data: [String: Any]) {
        guard let content = data["content"] as? String else {
            return
        }

        self.coordinator?.setAmount(content)
    }

    @objc func memo(_ data: [String: Any]) {
        guard let content = data["content"] as? String else { return }

        if !content.isEmpty, !UserManager.shared.permission.withdraw, UserManager.shared.unlockType == .cloudPassword {
            showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
            return
        }
        self.coordinator?.setMemo(content)
    }
}

extension TransferViewController {
    @objc func switchStatusDidSwitched(_ data: [String: Any]) {
        transferView.contentView.updateContentSize()
        transferView.updateContentSize()
        switchVestingObservable.onNext(transferView.postVestingView.switchStatus)
    }

    @objc func choosePubKeyDidClicked(_ data: [String: Any]) {
        guard let toAccount = self.coordinator?.state.toAccount.value else {
            return
        }
    
        self.coordinator?.presentPubKeyOptions(toAccount.activePubKeys, pubkeyChoosedIndex: {[weak self] (index) in
            guard let self = self else { return }

            let pubkey = toAccount.activePubKeys[index]
            self.transferView.postVestingView.setPubkey(pubkey)
            self.transferView.contentView.updateContentSize()
            self.transferView.updateContentSize()
        })
    }

    @objc func dropDownBoxViewDidClicked(_ data: [String: Any]) {
        self.coordinator?.openDropBoxViewController()
    }

    @objc func showHintContent(_ data: [String: Any]) {
        let v = BalanceIntroduceView(frame: UIScreen.main.bounds)
        v.title.locali = R.string.localizable.vesting_lock_time_hint_title.key
        v.content.locali = R.string.localizable.vesting_lock_time_hint.key

        UIApplication.shared.keyWindow?.addSubview(v)
    }
}

extension TransferViewController {
    override func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.transferView.postVestingView.dropButton.resetState()

        return true
    }
}

extension TransferViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String, index: Int) {
        selectedVestingTimeIndex = index
        self.transferView.postVestingView.dropButton.nameLabel.text = info
        self.transferView.postVestingView.dropButton.resetState()

        sender.dismiss(animated: true, completion: nil)
    }
}
