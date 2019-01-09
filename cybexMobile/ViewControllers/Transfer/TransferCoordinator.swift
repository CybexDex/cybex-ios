//
//  TransferCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Presentr
import NBLCommonModule
import HandyJSON
import cybex_ios_core_cpp

struct TransferContext: RouteContext, HandyJSON {
    init() {}
}

protocol TransferCoordinatorProtocol {
    func pushToRecordVC()

    func showPicker()

    func openAddTransferAddress(_ sender: TransferAddress)

    func reopenAction()
}

protocol TransferStateManagerProtocol {
    var state: TransferState { get }

    //获取转账收款人信息
    func getTransferAccountInfo()

    func setAccount(_ account: String)

    func setAmount(_ amount: String, canFetchFee: Bool)

    func setMemo(_ memo: String, canFetchFee: Bool)

    func validAmount()

    func validAccount()

    func checkAmount(_ transferAmount: Decimal)

    func transfer(_ callback: @escaping (Any) -> Void)

    func getGatewayFee(_ assetId: String, amount: String, memo: String)

    func chooseOrAddAddress()

    func dispatchAccountAction(_ type: AccountValidStatus)

}

class TransferCoordinator: NavCoordinator {
    var store = Store<TransferState>(
        reducer: transferReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.recode.transferViewController()!
        let coordinator = TransferCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))

        return vc
    }

    override func register() {
        Broadcaster.register(TransferCoordinatorProtocol.self, observer: self)
        Broadcaster.register(TransferStateManagerProtocol.self, observer: self)
    }
}

extension TransferCoordinator: TransferCoordinatorProtocol {
    func pushToRecordVC() {
        let recordVC = R.storyboard.recode.transferListViewController()
        let coordinator = TransferListCoordinator(rootVC: self.rootVC)
        recordVC?.coordinator = coordinator
        self.rootVC.pushViewController(recordVC!, animated: true)

    }

    func showPicker() {
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
                if let info = appData.assetInfo[balance.assetType] {
                    items.append(info.symbol.filterJade)
                }
            }
        }

        if items.count == 0 {
            items.append(R.string.localizable.balance_nodata.key.localized())
        }

        var context = PickerContext()
        context.items = items as AnyObject
        context.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
            guard let self = self else { return }
            self.getTransferAccountInfo()
            if let balance = balances, balance.count > 0 {
                self.store.dispatch(SetBalanceAction(balance: balances![picker.selectedRow(inComponent: 0)]))
                self.validAmount()
            }
        }

        presentVC(PickerCoordinator.self, animated: true, context: context, navSetup: nil) { (top, target) in
            top.customPresentViewController(presenter, viewController: target, animated: true)
        }
    }

    func pop() {
        self.rootVC.popViewController(animated: true, nil)
    }

    func openAddAddress() {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.addressType = .transfer
            vc.asset = AssetConfiguration.CybexAsset.CYB.id
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func chooseAddress() {
        let width = ModalSize.full
        let height = ModalSize.custom(size: 244)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.dismissOnTap = true
        presenter.keyboardTranslationType = .moveUp

        let items = AddressManager.shared.getTransferAddressList()
        var context = PickerContext()
        context.items = items.map({ $0.name }) as AnyObject
        context.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
            guard let self = self else { return }
            let selectedIndex = picker.selectedRow(inComponent: 0)
            self.store.dispatch(CleanToAccountAction())
            self.store.dispatch(ValidAccountAction(status: .validSuccessed))
            self.store.dispatch(ChooseAccountAction(account: items[selectedIndex]))
            self.getTransferAccountInfo()
        }

        presentVC(PickerCoordinator.self, animated: true, context: context, navSetup: nil) { (top, target) in
            top.customPresentViewController(presenter, viewController: target, animated: true)
        }
    }

    func openAddTransferAddress(_ sender: TransferAddress) {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.addressType = .transfer
            vc.transferAddress = sender
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func reopenAction() {
        let transferVC = R.storyboard.recode.transferViewController()!
        let coordinator = TransferCoordinator(rootVC: self.rootVC)
        transferVC.coordinator = coordinator
        self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] = transferVC
    }
}

extension TransferCoordinator: TransferStateManagerProtocol {

    func dispatchAccountAction(_ type: AccountValidStatus) {
        self.store.dispatch(ValidAccountAction(status: type))
    }

    func transfer(_ callback: @escaping (Any) -> Void) {
        guard let balance = self.state.balance.value else {
            return
        }
        guard self.state.toAccount.value != nil else {
            return
        }
        guard let fee = self.state.fee.value else {
            return
        }
        let amount = self.state.amount.value

        CybexChainHelper.blockchainParams { (blockInfo) in
            if let assetInfo = appData.assetInfo[balance.assetType], let feeInfo = appData.assetInfo[fee.assetId] {
                let value = pow(10, assetInfo.precision)
                let amount = amount.decimal() * value

                guard let fromAccount = UserManager.shared.account.value, let toAccount = self.state.toAccount.value else {
                    return
                }

                let feeAmout = fee.amount.decimal() * pow(10, feeInfo.precision)

                let jsonstr =  BitShareCoordinator.getTransaction(blockInfo.block_num.int32,
                                                                  block_id: blockInfo.block_id,
                                                                  expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                                                  chain_id: CybexConfiguration.shared.chainID.value,
                                                                  from_user_id: fromAccount.id.getSuffixID,
                                                                  to_user_id: toAccount.id.getSuffixID,
                                                                  asset_id: balance.assetType.getSuffixID,
                                                                  receive_asset_id: balance.assetType.getSuffixID,
                                                                  amount: amount.int64Value,
                                                                  fee_id: fee.assetId.getSuffixID,
                                                                  fee_amount: feeAmout.int64Value,
                                                                  memo: self.state.memo.value,
                                                                  from_memo_key: fromAccount.memoKey,
                                                                  to_memo_key: toAccount.memoKey)

                let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                    main {
                        callback(data)
                    }
                }, jsonstr: jsonstr!)
                CybexWebSocketService.shared.send(request: withdrawRequest)
            }
        }
    }

    func validAccount() {
        if !self.state.account.value.isEmpty {
            if let vc = self.rootVC.topViewController as? TransferViewController {
                vc.transferView.accountView.loadingState = .loading
            }
            UserManager.shared.checkUserName(self.state.account.value).done({[weak self] (exist) in
                main {
                    guard let self = self else { return }
                    self.store.dispatch(ValidAccountAction(status: exist ? .validSuccessed : .validFailed))
                    if exist {
                        self.getTransferAccountInfo()
                    }
                }
            }).cauterize()
        }
    }

    func setAccount(_ account: String) {
        if !self.state.account.value.isEmpty, self.state.account.value != account {
            self.store.dispatch(ValidAccountAction(status: .unValided))
        }
        self.state.account.accept(account)
        validAccount()
    }

    func setAmount(_ amount: String, canFetchFee: Bool) {
        self.state.amount.accept(amount)
        if canFetchFee {
            validAmount()
        }
    }

    func setMemo(_ memo: String, canFetchFee: Bool) {
        self.state.memo.accept(memo)
        if canFetchFee {
            validAmount()
        }
    }

    func validAmount() {
        let balance = self.state.balance.value
        getGatewayFee(balance?.assetType ?? "", amount: self.state.amount.value, memo: self.state.memo.value)
    }

    func getTransferAccountInfo() {
        if self.state.accountValid.value == .validSuccessed {
            let requeset = GetFullAccountsRequest(name: self.state.account.value) { (response) in
                if let data = response as? FullAccount, let account = data.account {
                    self.store.dispatch(SetToAccountAction(account: account))
                }
            }
            CybexWebSocketService.shared.send(request: requeset)
        }
    }

    func getGatewayFee(_ assetId: String, amount: String, memo: String) {
        let value = assetId.isEmpty ? 1 : pow(10, (appData.assetInfo[assetId]?.precision)!)
        let fromUserId = UserManager.shared.account.value?.id ?? "0"
        let fromMemoKey = UserManager.shared.account.value?.memoKey ?? ""
        let toUserId = self.state.toAccount.value?.id ?? "0"
        let toMemoKey = self.state.toAccount.value?.memoKey ?? fromMemoKey
        if let operationString = BitShareCoordinator.getTransterOperation(fromUserId.getSuffixID,
                                                                          to_user_id: toUserId.getSuffixID,
                                                                          asset_id: assetId.getSuffixID,
                                                                          amount: 0,
                                                                          fee_id: 0,
                                                                          fee_amount: 0,
                                                                          memo: memo,
                                                                          from_memo_key: fromMemoKey,
                                                                          to_memo_key: toMemoKey) {
            CybexChainHelper.calculateFee(operationString, operationID: .transfer, focusAssetId: assetId) { (success, amount, feeId) in
                let dictionary = ["asset_id": feeId, "amount": amount.stringValue]

                self.store.dispatch(SetFeeAction(fee: Fee.deserialize(from: dictionary)!))
                if success {
                    var transferAmount = self.state.amount.value.decimal()
                    let value = assetId.isEmpty ? 1 : pow(10, (appData.assetInfo[assetId]?.precision)!)
                    transferAmount *= value
                    self.checkAmount(transferAmount)

                } else {
                    if self.state.amount.value.decimal() != 0 {
                        self.store.dispatch(ValidAmountAction(isValid: false))
                    }
                    //            self.store.dispatch(ValidAmountAction(isValid: false))
                }
            }
        }

    }

    func checkAmount(_ transferAmount: Decimal) {
        if let balance = self.state.balance.value {
            let totalAmount = balance.balance.decimal()
            
            var feeAmount: Decimal = 0
            if let fee = self.state.fee.value {
                if fee.assetId == balance.assetType {
                    feeAmount = fee.amount.decimal()
                    let value = fee.assetId.isEmpty ? 1 : pow(10, (appData.assetInfo[fee.assetId]?.precision)!)
                    feeAmount *= value
                }
            }
            if transferAmount + feeAmount > totalAmount {
                self.store.dispatch(ValidAmountAction(isValid: false))
            } else {
                self.store.dispatch(ValidAmountAction(isValid: true))
            }
        } else {
            self.store.dispatch(ValidAmountAction(isValid: true))
        }
    }

    var state: TransferState {
        return store.state
    }

    func chooseOrAddAddress() {
        if AddressManager.shared.getTransferAddressList().count == 0 {
            self.openAddAddress()
        } else {
            self.chooseAddress()
        }
    }

}
