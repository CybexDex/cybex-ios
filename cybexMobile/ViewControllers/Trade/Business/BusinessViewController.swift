//
//  BusinessViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import Localize_Swift
import SwifterSwift

class BusinessViewController: BaseViewController {
    var pair: Pair? {
        didSet {
            if oldValue != pair {
                self.coordinator?.resetState()
                fetchLatestPrice()
                refreshView()
            }
            
            if self.pricePricision == 0 {
                fetchLatestPrice()
            }
        }
    }
    
    @IBOutlet weak var containerView: BusinessView!
    
    var type: ExchangeType = .buy
    
    var coordinator: (BusinessCoordinatorProtocol & BusinessStateManagerProtocol)?
    
    var pricePricision: Int = 0
    var amountPricision: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEvent()
    }
    
    func fetchLatestPrice() {
        guard let pair = pair, let _ = MarketConfiguration.marketBaseAssets.map({ $0.id }).index(of: pair.base) else { return }
        if let selectedIndex = MarketHelper.filterQuoteAssetTicker(pair.base).index(where: { (ticker) -> Bool in
            return ticker.quote == pair.quote
        }) {
            let markets = MarketHelper.filterQuoteAssetTicker(pair.base)
            let data = markets[selectedIndex]
            pricePricision = data.latest.tradePriceAndAmountDecimal().pricision
            amountPricision = data.latest.tradePriceAndAmountDecimal().amountPricision
        }
    }
    
    func setupUI() {
        containerView.button.gradientLayer.colors = type == .buy ?
            [UIColor.paleOliveGreen.cgColor, UIColor.apple.cgColor] :
            [UIColor.pastelRed.cgColor, UIColor.reddish.cgColor]
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification),
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
                                                guard let self = self else { return }
                                                
                                                if ThemeManager.currentThemeIndex == 0 {
                                                    self.containerView.priceTextfield.textColor = .white
                                                    self.containerView.amountTextfield.textColor = .white
                                                } else {
                                                    self.containerView.priceTextfield.textColor = .darkTwo
                                                    self.containerView.amountTextfield.textColor = .darkTwo
                                                }
                                                
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](_) in
            guard let self = self else { return }
            
            self.containerView.amountTextfield.placeholder = R.string.localizable.withdraw_amount.key.localized()
            self.containerView.priceTextfield.placeholder = R.string.localizable.orderbook_price.key.localized()
            self.containerView.amountTextfield.setPlaceHolderTextColor(UIColor.steel50)
            self.containerView.priceTextfield.setPlaceHolderTextColor(UIColor.steel50)
            self.changeButtonState()
        }
    }
    
    func refreshView() {
        guard let pair = pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] else { return }
        
        self.containerView.quoteName.text = quoteInfo.symbol.filterJade
        
        self.coordinator?.getFee(self.type == .buy ? baseInfo.id : quoteInfo.id)
        
        self.coordinator?.getBalance((self.type == .buy ? baseInfo.id : quoteInfo.id))
        
        changeButtonState()
    }
    
    @discardableResult func checkBalance() -> Bool {
        guard let pair = self.pair else {
            self.containerView.tipView.isHidden = true
            
            return false
        }
        
        guard let canPost = self.coordinator?.checkBalance(pair, isBuy: self.type == .buy) else {
            if let amount =  self.containerView.amountTextfield.text,
                amount.decimal() > 0,
                let price =  self.containerView.priceTextfield.text,
                price.decimal() > 0 {
                self.containerView.tipView.isHidden = false
            } else {
                self.containerView.tipView.isHidden = true
            }
            return false
        }
        
        if !canPost {
            self.containerView.tipView.isHidden = false
            return false
        } else {
            self.containerView.tipView.isHidden = true
            return true
        }
    }
    
    func changeButtonState() {
        if UserManager.shared.isLoginIn {
            guard let pair = pair, let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.containerView.button.locali = self.type == .buy ? R.string.localizable.openedBuy.key : R.string.localizable.openedSell.key
            if let title = self.containerView.button.button.titleLabel?.text {
                self.containerView.button.button.setTitle("\(title) \(quoteInfo.symbol.filterJade)", for: .normal)
            }
        } else {
            self.containerView.button.locali = R.string.localizable.business_login_title.key
        }
    }
    
    func showOpenedOrderInfo() {
        guard let baseInfo = appData.assetInfo[(self.pair?.base)!],
            let quoteInfo = appData.assetInfo[(self.pair?.quote)!],
            let _ = appData.assetInfo[(self.coordinator?.state.feeID.value)!],
            self.coordinator?.state.feeAmount.value != 0,
            let curAmount = self.coordinator?.state.amount.value,
            let price = self.coordinator?.state.price.value
            else { return }
        
        let decimalAmount = curAmount.decimal()
        let decimalPrice = price.decimal()
        
        guard  decimalAmount != 0, decimalPrice != 0 else { return }
        
        let openedOrderDetailView = StyleContentView(frame: .zero)
        let ensureTitle = self.type == .buy ?
            R.string.localizable.openedorder_buy_ensure.key.localized() :
            R.string.localizable.openedorder_sell_ensure.key.localized()
        
        ShowToastManager.shared.setUp(title: ensureTitle, contentView: openedOrderDetailView, animationType: .upDown)
        ShowToastManager.shared.showAnimationInView(self.view)
        ShowToastManager.shared.delegate = self
        
        let prirce = decimalPrice.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
        let amount = decimalAmount.string(digits: quoteInfo.precision, roundingMode: .down)  + " " + quoteInfo.symbol.filterJade
        let total = (decimalPrice * decimalAmount).string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
        openedOrderDetailView.data = UIHelper.getOpenedOrderInfo(price: prirce, amount: amount, total: total, fee: "", isBuy: self.type == .buy)
    }
    
    override func configureObserveState() {
        
        (self.containerView.amountTextfield.rx.text.orEmpty <-> self.coordinator!.state.amount).disposed(by: disposeBag)
        (self.containerView.priceTextfield.rx.text.orEmpty <-> self.coordinator!.state.price).disposed(by: disposeBag)
        
        self.addObserverSubscribeAction()
        self.addNotificationSubscribeAction()
        self.addUserManagerObserverSubscribeAction()
        
        //balance
        self.coordinator?.state.balance.asObservable().skip(1).subscribe(onNext: {[weak self] (balance) in
            guard let self = self else { return }
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote], balance != 0 else {
                self.containerView.balance.text = "--"
                
                if let amount = self.containerView.amountTextfield.text,
                    amount.decimal() > 0,
                    let price =  self.containerView.priceTextfield.text,
                    price.decimal() > 0 {
                    self.containerView.tipView.isHidden = false
                }
                return
            }
            
            let info = self.type == .buy ? baseInfo : quoteInfo
            let symbol = info.symbol.filterJade
            let realAmount = balance.string(digits: info.precision)
            
            self.containerView.balance.text = "\(realAmount) \(symbol)"
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //fee
        Observable.combineLatest(coordinator!.state.feeID.asObservable(), coordinator!.state.feeAmount.asObservable()).subscribe(onNext: {[weak self] (feeId, feeAmount) in
            guard let self = self else { return }
            
            guard let info = appData.assetInfo[feeId] else {
                self.containerView.fee.text = "--"
                return
            }
            self.containerView.fee.text = feeAmount.string(digits: info.precision) + " \(info.symbol.filterJade)"
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //total
        Observable.combineLatest(coordinator!.state.feeID.asObservable(),
                                 self.coordinator!.state.amount,
                                 self.coordinator!.state.price,
                                 coordinator!.state.feeAmount.asObservable())
            .subscribe(onNext: {[weak self] (_, amount, price, fee) in
                guard let self = self else { return }
                guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base] else {
                    self.containerView.endMoney.text = "--"
                    return
                }
                guard price.decimal() != 0, amount.decimal() != 0, fee != 0 else {
                        self.containerView.endMoney.text = "--"
                        return
                }
                let total = price.decimal() * amount.decimal()
                guard let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0 else {
                    self.containerView.endMoney.text = "\(total.string(digits: self.pricePricision, roundingMode: .down)) \(baseInfo.symbol.filterJade)"
                    return
                }
                self.containerView.endMoney.text = "\(total.string(digits: self.pricePricision, roundingMode: .down)) \(baseInfo.symbol.filterJade)"
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func addUserManagerObserverSubscribeAction() {
        
        UserManager.shared.balances.asObservable().subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.coordinator?.getBalance((self.type == .buy ? baseInfo.id : quoteInfo.id))
            self.coordinator?.getFee(self.type == .buy ? baseInfo.id : quoteInfo.id)
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        UserManager.shared.name.skip(1).asObservable().subscribe(onNext: {[weak self] (name) in
            guard let self = self else { return }
            
            self.changeButtonState()
            
            guard let _ = name else {
                self.coordinator?.resetState()
                return
            }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func addObserverSubscribeAction() {
        //RMB
        self.coordinator!.state.price.subscribe(onNext: {[weak self] (text) in
            guard let self = self else { return }
            self.checkBalance()
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base],
                let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0,
                text.components(separatedBy: ".").count <= 2 && text != "." else {
                    self.containerView.value.text = "≈¥0.0000"
                    return
            }
            self.containerView.value.text = "≈¥" + (AssetHelper.singleAssetRMBPrice(baseInfo.id) * text.decimal()).string(digits: 4, roundingMode: .down)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator!.state.amount.subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            
            self.checkBalance()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func addNotificationSubscribeAction() {
        //precision
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self.containerView.priceTextfield, queue: nil) {[weak self] (_) in
            guard let self = self else { return }
            
            guard let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0 else {
                self.containerView.priceTextfield.text = ""
                self.coordinator?.switchPrice("")
                return
            }
            
            let texts = text.replacingOccurrences(of: ",", with: "").components(separatedBy: ".")
            if let price = texts.first, price.count > 8 {
                self.containerView.priceTextfield.text = price.substring(from: 0, length: 8)
                if texts.count > 1 {
                    self.containerView.priceTextfield.text = self.containerView.priceTextfield.text! + "." + texts.last!
                }
            }
            
            self.containerView.priceTextfield.text = self.containerView.priceTextfield.text!.formatCurrency(digitNum: self.pricePricision)
            self.coordinator?.switchPrice(self.containerView.priceTextfield.text!)
            
            guard let amountText = self.containerView.amountTextfield.text, amountText != "", amountText.decimal() != 0 else {
                return
            }
            self.containerView.amountTextfield.text = amountText.decimal().string(digits: self.amountPricision, roundingMode: .down)
            self.coordinator?.state.price.accept(self.containerView.priceTextfield.text!)
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self.containerView.amountTextfield, queue: nil) {[weak self] (_) in
            guard let self = self else { return }
            
            guard let text = self.containerView.amountTextfield.text, text != "", text.decimal() != 0 else {
                self.containerView.amountTextfield.text = ""
                return
            }
            
            let texts = text.replacingOccurrences(of: ",", with: "").components(separatedBy: ".")
            if let amount = texts.first, amount.count > 8 {
                self.containerView.amountTextfield.text = amount.substring(from: 0, length: 8)
                if texts.count > 1 {
                    self.containerView.amountTextfield.text = self.containerView.amountTextfield.text! + "." + texts.last!
                }
            }
            self.containerView.amountTextfield.text = self.containerView.amountTextfield.text!.formatCurrency(digitNum: self.amountPricision)
            
            self.coordinator?.changeAmountAction(self.containerView.amountTextfield.text!)
            guard let priceText = self.containerView.priceTextfield.text, priceText != "", priceText.decimal() != 0 else {
                return
            }
            self.coordinator?.state.amount.accept(self.containerView.amountTextfield.text!)
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self.containerView.amountTextfield, queue: nil) {[weak self](_) in
            guard let self = self else {return}
            if !UserManager.shared.isLoginIn {
                self.containerView.amountTextfield.resignFirstResponder()
                appCoodinator.showLogin()
                return
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self.containerView.priceTextfield, queue: nil) {[weak self](_) in
            guard let self = self else {return}
            
            if !UserManager.shared.isLoginIn {
                self.containerView.priceTextfield.resignFirstResponder()
                appCoodinator.showLogin()
                return
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.containerView.priceTextfield)
        NotificationCenter.default.removeObserver(self.containerView.amountTextfield)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
    }
}

extension BusinessViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }
    
    func refresh() {
        //    refreshView()
    }
}

extension BusinessViewController {
    @objc func amountPercent(_ data: [String: Any]) {
        if let percent = data["percent"] as? String {
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.coordinator?.changePercent(percent.decimal() / 100.0,
                                            isBuy: self.type == .buy,
                                            assetID: self.type == .buy ? baseInfo.id : quoteInfo.id,
                                            pricision: self.amountPricision)
        }
    }
    
    @objc func buttonDidClicked(_ data: [String: Any]) {
        self.containerView.priceTextfield.endEditing(true)
        self.containerView.amountTextfield.endEditing(true)
        if self.coordinator!.parentIsLoading(self.parent) {
            return
        }
        
        if !UserManager.shared.isLoginIn {
            appCoodinator.showLogin()
            return
        }
        
        guard checkBalance() else { return }
        
        //    if UserManager.shared.isLocked {
        //      showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
        //    }
        //    else {
        self.showOpenedOrderInfo()
        //    }
    }
    
    @objc func adjustPrice(_ data: [String: Bool]) {
        if self.pricePricision == 0 {
            return
        }
        self.coordinator?.adjustPrice(data["plus"]!, pricePricision: self.pricePricision)
    }
    
    func postOrder() {
        guard let pair = self.pair else { return }
        
        self.coordinator?.postLimitOrder(pair, isBuy: self.type == .buy, callback: {[weak self] (success) in
            guard let self = self else { return }
            self.coordinator?.parentEndLoading(self.parent)
            
            if success {
                self.coordinator?.resetState()
            }
            
            self.showToastBox(success, message: success ? R.string.localizable.order_create_success.key.localized() : R.string.localizable.order_create_fail.key.localized())
            
        })
    }
    
    override func returnEnsureAction() {
        //    self.coordinator?.parentStartLoading(self.parent)
        ShowToastManager.shared.hide()
        if UserManager.shared.isLocked {
            SwifterSwift.delay(milliseconds: 100) {
                self.showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
            }
        } else {
            self.coordinator?.parentStartLoading(self.parent)
            postOrder()
        }
    }
    
    override func passwordDetecting() {
        self.coordinator?.parentStartLoading(self.parent)
    }
    
    override func passwordPassed(_ passed: Bool) {
        
        if passed {
            postOrder()
        } else {
            self.coordinator?.parentEndLoading(self.parent)
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
        
    }
}
