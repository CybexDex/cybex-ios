//
//  DepolyTicketViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/9.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import Presentr
import RxCocoa
import RxSwift
import cybex_ios_core_cpp
import SwiftyJSON

class DepolyTicketViewController: BaseViewController {
    var containView: DeployTicketView!

    var chooseAsset: AssetInfo?
    var toAccount: Account?
    var transactionId:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.ticket_title.key.localized()

        setupUI()
        self.containView.buttonIsEnable = false

        setupEvent()
    }

    func setupUI() {
        let scroll = UIScrollView(frame: self.view.frame.inset(by: self.view.windowWithNavSafeAreaInsets))
        self.containView = DeployTicketView(frame: scroll.bounds)
        scroll.addSubview(self.containView)
        scroll.contentSize = scroll.size
        self.view.addSubview(scroll)
    }

    func setupEvent() {
        Observable.combineLatest(containView.accountView.textField.rx.text.orEmpty,
                                 containView.assetView.textField.rx.text.orEmpty,
                                 containView.amountView.textField.rx.text.orEmpty)
            .subscribe(onNext: {[weak self] (validate) in
            guard let self = self else { return }

            self.validateButtonState()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                               object: containView.accountView.textField,
                                               queue: nil) { (notifi) in
            guard let name = self.containView.accountView.textField.text else { return }

            self.toAccount = nil
            self.getAccountFrom(name)
        }

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                               object: containView.assetView.textField,
                                               queue: nil) { (notifi) in
            guard let asset = self.containView.assetView.textField.text else { return }

            self.chooseAsset = nil

            self.getAsset(asset)
        }
    }
}

// MARK: - Logic
extension DepolyTicketViewController {
    func validateButtonState() {
        if containView.accountView.textField.text!.isEmpty
            || containView.assetView.textField.text!.isEmpty
            || containView.amountView.textField.text!.isEmpty
            || self.chooseAsset == nil
            || self.toAccount == nil {
            self.containView.buttonIsEnable = false
        } else {
            self.containView.buttonIsEnable = true
        }
    }
    
    func getAccountFrom(_ accountName: String) {
        let requeset = GetFullAccountsRequest(name: accountName) { (response) in
            if let data = response as? FullAccount, let account = data.account {
                self.toAccount = account
            } else {
                self.toAccount = nil
            }
            self.validateButtonState()
        }
        CybexWebSocketService.shared.send(request: requeset, priority: .veryHigh)
    }

    func getAsset(_ assetName: String) {
        let request = LookupAssetSymbolsRequest(names: [assetName]) { response in
            if let assetinfo = response as? [AssetInfo], let info = assetinfo.first {
                self.chooseAsset = info

                let requeset = GetFullAccountsRequest(name: UserManager.shared.name.value!) { (response) in
                    if let data = response as? FullAccount {
                        if let balances = data.balances {
                            for balance in balances {
                                if balance.assetType == info.id {
                                    let balanceDecimal = balance.balance.decimal()
                                    if balanceDecimal > 0 {
                                        self.containView.amountView.unitLabel.text = R.string.localizable.ticket_asset_left.key.localizedFormat(balanceDecimal.string(digits: 0, roundingMode: .down))
                                    }
                                    else {
                                        self.containView.amountView.unitLabel.text = R.string.localizable.ticket_asset_left.key.localizedFormat("-")
                                    }
                                }
                            }
                        }
                    }
                }
                CybexWebSocketService.shared.send(request: requeset, priority: .veryHigh)


            }
            else {
                self.chooseAsset = nil
            }
            self.validateButtonState()
        }
        CybexWebSocketService.shared.send(request: request, priority: .veryHigh)
    }

    func generateInfo(_ callback: @escaping (String?) -> Void) {
        guard let fromAccount = UserManager.shared.account.value,
            let amount = containView.amountView.textField.text,
            let asset = chooseAsset,
            let toAccount = toAccount else {
                callback(nil)
                return
        }

        let sendAmount = (amount.decimal() * pow(10, asset.precision)).int64Value
        let timeInterval = Date().timeIntervalSince1970 + CybexConfiguration.TransactionTicketExpiration
        CybexChainHelper.blockchainParamsRefLib { (blockInfo) in
            guard let jsonstr = BitShareCoordinator.getTransaction(blockInfo.block_num.int32,
                                                              block_id: blockInfo.block_id,
                                                              expiration: timeInterval,
                                                              chain_id: CybexConfiguration.shared.chainID.value,
                                                              from_user_id: fromAccount.id.getSuffixID,
                                                              to_user_id: toAccount.id.getSuffixID,
                                                              asset_id: asset.id.getSuffixID,
                                                              receive_asset_id: asset.id.getSuffixID,
                                                              amount: sendAmount,
                                                              fee_id: 0,
                                                              fee_amount: 1000,
                                                              memo: "",
                                                              from_memo_key: "",
                                                              to_memo_key: "") else {
                                                                callback(nil)
                                                                return
            }

            guard let transactionId = BitShareCoordinator.getTransactionId(blockInfo.block_num.int32, block_id: blockInfo.block_id, expiration: timeInterval, chain_id: CybexConfiguration.shared.chainID.value, from_user_id: fromAccount.id.getSuffixID, to_user_id: toAccount.id.getSuffixID, asset_id: asset.id.getSuffixID, receive_asset_id: asset.id.getSuffixID, amount: sendAmount, fee_id: 0, fee_amount: 1000, memo: "", from_memo_key: "", to_memo_key: "") else { return }

            self.transactionId = transactionId

            let result = CryptoHelper.compressTransaction(jsonstr,
                                                          timeInterval: timeInterval,
                                                          from: Int(fromAccount.id.getSuffixID),
                                                          to: Int(toAccount.id.getSuffixID),
                                                          assetId: Int(asset.id.getSuffixID),
                                                          amount: Int(sendAmount))

            callback(result)

        }
    }

    func ticketUse() {
        guard UserManager.shared.account.value != nil, let chooseAsset = chooseAsset else { return }

        startLoading()

        generateInfo {[weak self] (result) in
            guard let self = self else { return }
            self.endLoading()

            guard let result = result else {
                return
            }

            let vc = DeployTicketResultViewController()
            vc.qrcodeInfo = result
            vc.transactionId = self.transactionId
            vc.assetName = chooseAsset.symbol.filterJade
            self.navigationController?.pushViewController(vc)
        }
    }
}

// MARK: - Route
extension DepolyTicketViewController {
    func presentAssetPicker(_ assetChoosed: @escaping (String) -> Void) {
        let width = ModalSize.full
        let height = ModalSize.custom(size: 244)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.dismissOnTap = true
        presenter.keyboardTranslationType = .moveUp

        var items = [String]()
        let balances = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
            return AssetHelper.getRealAmount(balance.assetType, amount: balance.balance) != 0
        })

        if let balances = balances {
            for balance in balances {
                items.append(balance.assetType.originSymbol)
            }
        }

        if items.count == 0 {
            items.append(R.string.localizable.balance_nodata.key.localized())
        }

        var context = PickerContext()
        context.items = ["PRINCESS"] as AnyObject
        context.pickerDidSelected = {(picker: UIPickerView) -> Void in
//            if let balances = balances {
//                let balance = balances[picker.selectedRow(inComponent: 0)]
//                assetChoosed(balance.assetType.originSymbol)
//            }
            assetChoosed("PRINCESS")

        }

        let nav = BaseNavigationController()
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(PickerCoordinator.self, animated: false, context: context)

        var topside = self.navigationController

        while topside?.presentedViewController != nil {
            topside = topside?.presentedViewController as? BaseNavigationController
        }

        if let top = topside {
            top.customPresentViewController(presenter, viewController: nav, animated: true)
        }
    }
}

// MARK: - Event
extension DepolyTicketViewController {
    @objc func scan(_ data: [String: Any]) {
        let vc = ScanViewController()
        vc.scanResult.delegate(on: self) { (self, r) in
            self.containView.accountView.textField.text = r

            self.toAccount = nil
            self.getAccountFrom(r)
        }

        self.navigationController?.pushViewController(vc)
    }

    @objc func chooseAsset(_ data: [String: Any]) {
        presentAssetPicker {[weak self] (asset) in
            guard let self = self else { return }

            self.containView.assetView.textField.text = asset

            self.chooseAsset = nil
            self.getAsset(asset)
        }
    }

    @objc func deploy(_ data: [String: Any]) {
        if !UserManager.shared.isLocked {
            self.ticketUse()
        } else {
            self.showPasswordBox()
        }
    }

}

extension DepolyTicketViewController {
    override func passwordDetecting() {
        self.startLoading()
    }

    override func passwordPassed(_ passed: Bool) {
        self.endLoading()

        if passed {
            self.ticketUse()
        } else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }
}
