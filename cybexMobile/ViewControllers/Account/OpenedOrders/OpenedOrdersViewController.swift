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
import XLPagerTabStrip

enum OpenedOrdersViewControllerPageType {
    case exchange
    case account
}

class OpenedOrdersViewController: BaseViewController, IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: R.string.localizable.orders_my_open_order.key.localized())
    }

    var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?
    var pageType: OpenedOrdersViewControllerPageType = .account
    var pair: Pair? {
        didSet {
            if oldValue != pair {
                self.setupData()
            }
        }
    }
    var timer: Disposable?
    var containerView: UIView?
    var order: LimitOrderStatus?
    var cancleOrderInfo: [String: Any]?
    var isCancelAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        self.coordinator?.connect()
        self.startLoading()
        setupData()

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.timer?.dispose()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.startFetchOpenedOrders()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        disappear()
    }
    
    func setupUI() {
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
    
    func setupEvent() {

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
        self.timer?.dispose()

        timer = Observable<Int>.interval(3, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (n) in
            guard let self = self, let coor = self.coordinator else { return }
            if coor.checkConnectStatus() {
                self.setupData()
            }
            else {
                self.coordinator?.reconnect()
            }
        })
    }

    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let self = self, let limitOrders = data, self.isVisible else { return }
            self.endLoading()
            if limitOrders.count == 0 {
                self.view.showNoData(R.string.localizable.openedorder_nodata.key.localized(), icon: R.image.img_no_records.name)
                return
            }
            else {
                self.view.hiddenNoData()
            }
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

    func refresh() {

    }

    func resetView() {
        
    }

    func appear() {
        guard let pair = pair else { return }
        self.coordinator?.fetchOpenedOrder(pair)
    }

    func disappear() {
        self.timer?.dispose()
        self.timer = nil
        self.coordinator?.disconnect()
    }
}

extension OpenedOrdersViewController {
    @objc func cancelOrder(_ data: [String: Any]) {
        if self.isLoading() {
            return
        }

        if let order = data["order"] as? LimitOrderStatus {
            self.order = order

            self.isCancelAll = false

            if UserManager.shared.checkExistCloudPassword(), UserManager.shared.loginType == .nfc {
                let titleLocali = UserManager.shared.unlockType == .cloudPassword ? R.string.localizable.enotes_use_type_0.key : R.string.localizable.enotes_use_type_1.key
                self.showPureContentConfirm(R.string.localizable.tip_title.key.localized(), rightTitleLocali: titleLocali, ensureButtonLocali: R.string.localizable.alert_ensure.key, content: "openedorder_ensure_message", tag: "")
            } else {
                self.showPureContentConfirm()
            }
        }
    }

    @objc func cancelAllOrder(_ data: [String: Any]) {
        if self.isLoading() {
            return
        }

        isCancelAll = true

        if UserManager.shared.checkExistCloudPassword(), UserManager.shared.loginType == .nfc {
            let titleLocali = UserManager.shared.unlockType == .cloudPassword ? R.string.localizable.enotes_use_type_0.key : R.string.localizable.enotes_use_type_1.key
            self.showPureContentConfirm(R.string.localizable.tip_title.key.localized(), rightTitleLocali: titleLocali, ensureButtonLocali: R.string.localizable.alert_ensure.key, content: "open_order_confirm_cancel_all", tag: "")
        } else {
            self.showPureContentConfirm(content: "open_order_confirm_cancel_all")
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

    func postCancelAllOrder() {
        // order.isBuy ? pair.base : pair.quote
        if let coor = self.coordinator {
            coor.cancelAllOrder(pair) {[weak self] (success) in
                guard let self = self else { return }
                self.endLoading()
                self.showToastBox(success,
                                  message: success ?
                                    R.string.localizable.cancel_create_success.key.localized() :
                                    R.string.localizable.cancel_create_fail.key.localized())
            }
        }
    }
    
    override func passwordDetecting() {
        self.startLoading()
    }
    
    override func passwordPassed(_ passed: Bool) {
        self.endLoading()
        if passed {
            if isCancelAll {
                postCancelAllOrder()
            } else {
                postCancelOrder()
            }
        } else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }

    override func didClickedRightAction(_ tag: String) {
        if tag == R.string.localizable.enotes_use_type_0.key { //enotes
            if #available(iOS 11.0, *) {
                NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                    BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)

                    self.startLoading()
                    if self.isCancelAll {
                        self.postCancelAllOrder()
                    } else {
                        self.postCancelOrder()
                    }

                }
                NFCManager.shared.start()
            }
        } else {
            showPasswordBox()
        }
    }
    
    override func returnEnsureAction() {
        self.startLoading()
        ShowToastManager.shared.hide()

        if UserManager.shared.loginType == .nfc, UserManager.shared.unlockType == .nfc {
            if #available(iOS 11.0, *) {
                NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                    BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)
                    if self.isCancelAll {
                        self.postCancelAllOrder()
                    } else {
                        self.postCancelOrder()
                    }
                }
                NFCManager.shared.start()
            }
        } else if UserManager.shared.isLocked {
            showPasswordBox()
        } else {
            if isCancelAll {
                postCancelAllOrder()
            } else {
                postCancelOrder()
            }
        }
    }
}
