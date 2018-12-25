//
//  OpenedOrdersViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import TinyConstraints
import Localize_Swift
import cybex_ios_core_cpp
import Repeat

enum OpenedOrdersViewControllerPageType {
    case exchange
    case account
}

class OpenedOrdersViewController: BaseViewController {
    
    var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?
    var pageType: OpenedOrdersViewControllerPageType = .account
    var pair: Pair? {
        didSet {
            if oldValue != pair {
                self.setupData()
            }
        }
    }
    var timer: Repeater?
    var containerView: UIView?
    var order: LimitOrderStatus?
    var cancleOrderInfo: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _ = UserManager.shared.balance
        self.coordinator?.connect()
        self.startLoading()
        setupData()
    }
    
    func setupUI() {
        self.localizedText = R.string.localizable.openedTitle.key.localizedContainer()
        switchContainerView()
    }
    
    func setupData() {
        if self.pageType == .account {
            self.coordinator?.fetchAllOpenedOrder()
        }
        else {
            guard let pair = self.pair else { return }
            self.coordinator?.fetchOpenedOrder(pair)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coordinator?.disconnect()
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("tradeChooseIndexAction"), object: nil, queue: nil) { [weak self](notifi) in
            guard let self = self, let pair = self.pair,
                let userInfo = notifi.userInfo,
                let index = userInfo["selectedIndex"] as? Int else { return }
            if index == 2 {
                self.coordinator?.fetchOpenedOrder(pair)
            }
            else {
                self.coordinator?.disconnect()
            }
        }
    }
    
    func showOrderInfo() {
        guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }
        guard let order = self.order else {return}
        startLoading()
        CybexChainHelper.calculateFee(operation,
                                      operationID: .limitOrderCancel,
                                      focusAssetId: order.isBuyOrder() ? order.getPair().base : order.getPair().quote) { [weak self](success, amount, assetId) in
                                        guard let self = self else {return}
                                        self.endLoading()
                                        guard self.isVisible else {return}
                                        if success, let order = self.order {
                                            let ensureTitle = order.isBuyOrder() ?
                                                R.string.localizable.cancle_openedorder_buy.key.localized() :
                                                R.string.localizable.cancle_openedorder_sell.key.localized()

                                            if self.isVisible {
                                                self.showCancelOpenOrderConfirm(ensureTitle)
                                            }

                                        } else {
                                            if self.isVisible {
                                                self.showToastBox(false, message: R.string.localizable.withdraw_nomore.key.localized())
                                            }
                                        }
        }
    }
    
    func switchContainerView() {
        containerView?.removeFromSuperview()
        containerView = pageType == .account ? AccountOpenedOrdersView() : MyOpenedOrdersView()
        self.view.addSubview(containerView!)
        if let accountView = self.containerView as? AccountOpenedOrdersView {
            accountView.data = nil
        } else {
            setupEvent()
        }
        containerView?.edgesToDevice(vc: self,
                                     insets: TinyEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: 0,
                                                            right: 0),
                                     priority: .required,
                                     isActive: true,
                                     usingSafeArea: true)
    }
    
    func startFetchOpenedOrders() {
        if self.timer == nil {
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (note) in
                self.timer?.pause()
                self.timer = nil
            }
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
                self.startFetchOpenedOrders()
            }
        }
        self.timer?.pause()
        self.timer = nil
        
        self.timer = Repeater.every(.seconds(3)) {[weak self] _ in
            guard let self = self, let coor = self.coordinator else { return }
            if coor.checkConnectStatus() {
                self.setupData()
            }
            else {
                self.coordinator?.reconnect()
            }
        }
        timer?.start()
        
    }
    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let self = self, let limitOrders = data, self.isVisible else { return }
            self.endLoading()
            if let accountView = self.containerView as? AccountOpenedOrdersView {
                accountView.data = limitOrders
            } else if let pairOrder = self.containerView as? MyOpenedOrdersView {
                pairOrder.data = limitOrders
            }
            if self.timer == nil {
                self.startFetchOpenedOrders()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    deinit {
        self.timer?.pause()
        self.timer = nil
    }
}

extension OpenedOrdersViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }
}

extension OpenedOrdersViewController {
    @objc func cancelOrder(_ data: [String: Any]) {
        if self.isLoading() {
            return
        }
        if let order = data["order"] as? LimitOrderStatus {
            self.order = order
            if UserManager.shared.isLocked {
                if self.isLoading() {
                    return
                }
                showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
            } else {
                self.showOrderInfo()
            }
        }
    }
    
    func postCancelOrder() {
        // order.isBuy ? pair.base : pair.quote
        if let order = self.order, let coor = self.coordinator {
            coor.cancelOrder(order.orderId, feeId: order.isBuyOrder() ? order.getPair().base.assetID : order.getPair().quote.assetID, callback: {[weak self] (success) in
                guard let self = self else { return }
                self.endLoading()
                self.showToastBox(success,
                                  message: success ?
                                    R.string.localizable.cancel_create_success.key.localized() :
                                    R.string.localizable.cancel_create_fail.key.localized())
            })
        }
    }
    
    override func passwordDetecting() {
        self.startLoading()
    }
    
    override func passwordPassed(_ passed: Bool) {
        self.endLoading()
        if passed {
            showOrderInfo()
        } else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }
    
    override func returnEnsureAction() {
        self.startLoading()
        ShowToastManager.shared.hide()
        self.postCancelOrder()
    }
}
