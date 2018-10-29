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

enum OpenedOrdersViewControllerPageType {
    case exchange
    case account
}

class OpenedOrdersViewController: BaseViewController {

    var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?

    var pageType: OpenedOrdersViewControllerPageType = .account

    var pair: Pair? {
        didSet {
            if let pairOrder = self.containerView as? MyOpenedOrdersView {
                pairOrder.data = self.pair
            }
        }
    }

    var containerView: UIView?
    var order: LimitOrder?
    var cancleOrderInfo: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _ = UserManager.shared.balance
    }

    func setupUI() {
        self.localizedText = R.string.localizable.openedTitle.key.localizedContainer()

        switchContainerView()
    }

    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let `self` = self else { return }
            if let accountView = self.containerView as? MyOpenedOrdersView {

                accountView.sectionView.totalTitle.locali = R.string.localizable.my_opened_price.key
                accountView.sectionView.cybPriceTitle.locali = R.string.localizable.my_opened_filled.key
            }
        })
    }

    func showOrderInfo() {
        guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }
        guard let order = self.order else {return}
        startLoading()
        calculateFee(operation, focusAssetId: order.sellPrice.base.assetID, operationID: .limitOrderCancel) { [weak self](success, amount, assetId) in
            guard let `self` = self else {return}
            self.endLoading()

            guard self.isVisible else {
                return
            }

            if success, let order = self.order {
                let ensureTitle = order.isBuy ? R.string.localizable.cancle_openedorder_buy.key.localized() : R.string.localizable.cancle_openedorder_sell.key.localized()

                if let baseInfo = appData.assetInfo[order.sellPrice.base.assetID], let quoteInfo = appData.assetInfo[order.sellPrice.quote.assetID], let feeInfoValue = appData.assetInfo[assetId] {
                    var priceInfo = ""
                    var amountInfo = ""
                    var totalInfo = ""
                    let feeInfo = amount.string(digits: feeInfoValue.precision, roundingMode: .down) + " " + feeInfoValue.symbol.filterJade
                    if order.isBuy {
                        let baseAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
                        let quoteAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
                        priceInfo = (baseAmount / quoteAmount).string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                        let total = getRealAmount(order.sellPrice.base.assetID, amount: order.forSale)
                        let amounts = total / (baseAmount / quoteAmount)
                        amountInfo = amounts.string(digits: quoteInfo.precision, roundingMode: .down) + " " + quoteInfo.symbol.filterJade
                        totalInfo = total.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                    } else {
                        let baseAmount  = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
                        let quoteAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
                        priceInfo =  (baseAmount / quoteAmount).string(digits: quoteInfo.precision, roundingMode: .down) + " " + quoteInfo.symbol.filterJade
                        let amounts = getRealAmount(order.sellPrice.base.assetID, amount: order.forSale)
                        var total: Decimal = 0
                        if order.forSale == order.sellPrice.base.amount {
                            total = baseAmount
                        } else {
                            total = amounts * (baseAmount / quoteAmount)
                        }
                        totalInfo = total.string(digits: quoteInfo.precision, roundingMode: .down) + " " + quoteInfo.symbol.filterJade
                        amountInfo = amounts.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                    }

                    if self.isVisible {
                        self.showConfirm(ensureTitle, attributes: getOpenedOrderInfo(price: priceInfo, amount: amountInfo, total: totalInfo, fee: feeInfo, isBuy: order.isBuy))
                    }
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
        containerView?.edgesToDevice(vc: self, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: .required, isActive: true, usingSafeArea: true)
    }

    override func configureObserveState() {
        UserManager.shared.limitOrder.asObservable().skip(1).subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }

            if let accountView = self.containerView as? AccountOpenedOrdersView {
                accountView.data = nil
            } else if let pairOrder = self.containerView as? MyOpenedOrdersView {
                pairOrder.data = self.pair
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
}

extension OpenedOrdersViewController {
    @objc func cancelOrder(_ data: [String: Any]) {
        if self.isLoading() {
            return
        }
        if let order = data["order"] as? LimitOrder {
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
        if let order = self.order {

            self.coordinator?.cancelOrder(order.id, feeId: order.sellPrice.base.assetID, callback: {[weak self] (success) in
                guard let `self` = self else { return }

                self.endLoading()
                self.showToastBox(success, message: success ? R.string.localizable.cancel_create_success.key.localized() : R.string.localizable.cancel_create_fail.key.localized())
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
