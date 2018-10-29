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

class TransferViewController: BaseViewController {

    @IBOutlet weak var transferView: TransferView!
    var accountName: String = ""

    var coordinator: (TransferCoordinatorProtocol & TransferStateManagerProtocol)?

    var isFetchFee: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getFee()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.transferView.accountView.reloadData()
    }

    override func configureObserveState() {
        self.transferView.transferButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }

            self.clickTransferAction()
        }).disposed(by: disposeBag)

        //按钮状态监听
        Observable.combineLatest(self.coordinator!.state.accountValid.asObservable(),
                                 self.coordinator!.state.amountValid.asObservable()).subscribe(onNext: {[weak self] (accountValid, amountValid) in
                                    guard let `self` = self else { return }
                                    if let _ = self.coordinator?.state.balance.value, let transferAmount = self.coordinator?.state.amount.value.toDouble() {
                                        self.transferView.buttonIsEnable = accountValid == .validSuccessed && amountValid && transferAmount > 0
                                    } else {
                                        self.transferView.buttonIsEnable = false
                                    }
                                    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //账户监听
        self.coordinator!.state.accountValid.asObservable().subscribe(onNext: {[weak self] (status) in
            guard let `self` = self else { return }
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
            guard let `self` = self else { return }
            if !result, ((self.coordinator?.state.fee.value) != nil), self.coordinator?.state.balance.value != nil, self.transferView.balance.count != 0 {
                self.showToastBox(false, message: R.string.localizable.transfer_balance_unenough.key.localized())
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //币种及余额监听
        self.coordinator!.state.balance.asObservable().subscribe(onNext: {[weak self] (balance) in
            guard let `self` = self else { return }
            if let balance = balance, let balanceInfo = appData.assetInfo[balance.assetType] {
                if let info = appData.assetInfo[balance.assetType] {
                    self.transferView.crypto = info.symbol.filterJade
                    self.transferView.precision = info.precision
                    let realBalance = getRealAmountDouble(balance.assetType, amount: balance.balance)
                    let transferBalanceKey = R.string.localizable.transfer_balance.key.localized()
                    self.transferView.balance = transferBalanceKey + realBalance.string(digits: info.precision) + " " + balanceInfo.symbol.filterJade
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //手续费监听
        self.coordinator!.state.fee.asObservable().subscribe(onNext: {[weak self] (result) in
            guard let `self` = self else { return }
            if let data = result, let feeInfo = appData.assetInfo[data.assetId] {
                let fee = data
                self.transferView.fee = (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.transferView.accountView.unitLabel.rx.tapGesture().when(.recognized).asObservable().subscribe(onNext: { [weak self](_) in
            guard let `self` = self else { return }
            self.coordinator?.chooseOrAddAddress()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        self.coordinator?.state.account.asObservable().skip(1).subscribe(onNext: { [weak self](account) in
            guard let `self` = self else { return }
            self.transferView.accountView.textField.text = account
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    func setupUI() {
        self.title = R.string.localizable.transfer_title.key.localized()
        self.configRightNavButton(R.image.ic_records_24_px())
        self.configLeftNavigationButton(nil)
    }

    func getFee() {
        if !UserManager.shared.isLocked {
            self.coordinator?.validAmount()
        } else {
            self.showPasswordBox()
        }
    }

    func clickTransferAction() {
        self.view.endEditing(true)
        if self.transferView.accountView.loadingState != .success ||
            self.coordinator!.state.accountValid.value != AccountValidStatus.validSuccessed {
            self.transferView.accountView.loadingState = .normal
            return
        }
        if !UserManager.shared.isLocked {
            self.transferComfirm()
        } else {
            self.showPasswordBox()
        }
    }

    func transferComfirm() {
        if let account = self.transferView.accountView.textField.text,
            let balance = self.coordinator?.state.balance.value,
            let amount = self.transferView.quantityView.textField.text,
            let memo = self.transferView.memoView.textView.text,
            let fee = self.coordinator?.state.fee.value {
            if let feeInfo = appData.assetInfo[fee.assetId] {
                let data = getTransferInfo(account,
                                           quanitity: amount + " " + (appData.assetInfo[balance.assetType]?.symbol.filterJade)!,
                                           fee: (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade,
                                           memo: memo)
                showConfirm(R.string.localizable.transfer_ensure_title.key.localized(), attributes: data)
            }
        }
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
            if self.isFetchFee == true {
                self.isFetchFee = false
                self.coordinator?.validAmount()
            } else {
                self.transferComfirm()

            }
        } else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }

    override func returnEnsureAction() {
        ShowToastManager.shared.hide()
        if !UserManager.shared.isLocked {

            if !UserManager.shared.isWithDraw, self.coordinator?.state.memo.value.count != 0 {
                showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
                return
            }

            self.startLoading()
            self.coordinator?.transfer({ [weak self](data) in
                guard let `self` = self else { return }
                self.endLoading()
                main {
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
                }
            })
        } else {
            SwifterSwift.delay(milliseconds: 300) {
                self.showPasswordBox()
            }
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
        self.coordinator?.setAmount(content, canFetchFee: !UserManager.shared.isLocked)
        if UserManager.shared.isLocked {
            self.isFetchFee = true
            self.showPasswordBox()
        }
    }

    @objc func memo(_ data: [String: Any]) {
        guard let content = data["content"] as? String else { return }
        if !UserManager.shared.isWithDraw {
            showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
            return
        }
        self.coordinator?.setMemo(content, canFetchFee: !UserManager.shared.isLocked)
        if UserManager.shared.isLocked {
            self.isFetchFee = true
            self.showPasswordBox()
        }
    }
}
