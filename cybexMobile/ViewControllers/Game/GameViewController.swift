//
//  GameViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/12/7.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import JavaScriptCore
import WebKit
import WKWebViewJavascriptBridge
import cybex_ios_core_cpp
import PromiseKit


class GameViewController: BaseViewController {
    
    var gameURL:String?
    let jsObjectName = "Potral"
    var coordinator: (GameCoordinatorProtocol & GameStateManagerProtocol)?
    var webView: WKWebView!
    var bridge: WKWebViewJavascriptBridge!
    
    var seal: Resolver<String>?
    var account: String?
    var asset: String?
    var amount: String?
    
    enum GameJSEvent: String {
        case timeout
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        self.webView = WKWebView(frame: .zero,configuration: configuration)
        self.webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        self.webView.edgesToDevice(vc: self, isActive: true, usingSafeArea: true)
        bridge = WKWebViewJavascriptBridge(webView: webView)
    }
    
    func setupData() {
        //dev 10.18.120.22:5552
        //pro  http://10.18.120.241:5552
        // https://cybexluck.io/
        if let gameURL = self.gameURL,
            let url = URL(string: gameURL) {
            self.setupLoadUrl(url)
        }
        self.bridgeRegisterAction()
    }
    
    func setupLoadUrl(_ url: URL) {
        let request = NSURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        self.webView.load(request as URLRequest)
    }
    
    func setupEvent() {
        
    }
    
    
    func clearCatch() {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dataFrom = Date.init(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: dataFrom) {
        }
    }
    
    override func configureObserveState() {
        
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
            
            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))
                
            case .loading(let reason):
                if reason == .initialRefresh {
                }
                
            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))
                
            case .loadMore(let page):
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))
                
            case .noMore:
                
                break
                
            case .noData:
                
                break
                
            case .normal(_):
                
                break
                
            case .error(_, _):
                
                break
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardDidShowNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let self = self else {return}
            self.webView.scrollView.isScrollEnabled = false
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardDidHideNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let self = self else {return}
            self.webView.scrollView.isScrollEnabled = true
        }
    }
}

extension GameViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
}

extension GameViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        self.clearCatch()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }
}


extension GameViewController {
    override func passwordDetecting() {
        
    }
    
    override func cancelImageAction(_ sender: CybexTextView) {
        self.seal?.fulfill("3")
    }
    
    override func passwordPassed(_ passed: Bool) {
        if !passed {
            self.seal?.fulfill("1")
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
        else {
            guard let account = self.account,
                let asset = self.asset,
                let amount = self.amount,
                let seal = self.seal else {
                    return
            }
            self.getRequireFee(account, asset , amount, seal)
        }
    }
}



extension GameViewController {
    func bridgeRegisterAction() {
        bridge.register(handlerName: "getUserName") { (paramters, callback) in
            callback?(self.getUserName())
        }
        
        bridge.register(handlerName: "searchBalanceWithAsset") { (paramters, callback) in
            if let param = paramters,
                let assetName = param["asset"] as? String
            {
                callback?(self.searchBalanceWithAsset(assetName))
            }
            else {
                callback?("")
            }
        }

        bridge.register(handlerName: "jsOpenUrl") { (paramters, callback) in
            if let param = paramters,
                let depositUrl = param["url"] as? String {
                self.openURL(depositUrl);
            }
        }
        
        bridge.register(handlerName: "transfer") { (paramters, callback) in
            if let param = paramters as? [String: String],
                let accountId = param["accountId"],
                let assetId = param["assetId"],
                let assetAmount = param["assetAmount"]{
                async {
                    let data = try? await(self.transfer(accountId, assetId, assetAmount))
                    main {
                        if case let data? = data {
                            callback?(data)
                        }
                    }
                }
            }
            else{
                callback?("2")
            }
        }
    }
    
    
    func getUserName() -> String {
        guard let user = UserManager.shared.name.value else {
            return ""
        }
        return user
    }
    
    func jsOpenUrl(_ url: String) {
        openPage(url)
    }
    
    func searchBalanceWithAsset(_ asset: String) -> String {
        guard let balances = UserManager.shared.balances.value else {
            return "0"
        }
        for balance in balances {
            if let balanceInfo = appData.assetInfo[balance.assetType], balanceInfo.symbol.filterJade == asset.filterJade {
                return AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).string(digits: balanceInfo.precision, roundingMode: .down)
            }
        }
        return "0"
    }
    
    func transfer(_ account: String, _ asset: String, _ amount: String) -> PromiseKit.Promise<String>  {
        let (promise, seal) = PromiseKit.Promise<String>.pending()
        // 先调手续费
        if !UserManager.shared.isLocked {
            self.getRequireFee(account, asset, amount, seal)
        }
        else {
            self.seal = seal
            self.account = account
            self.asset = asset
            self.amount = amount
            self.showPasswordBox()
        }
        return promise
    }
    
    
    func getRequireFee(_ account: String, _ asset: String, _ amount: String , _ seal: Resolver<String>) {
        let requeset = GetFullAccountsRequest(name: account) { (response) in
            if let data = response as? FullAccount,
                let accountInfo = data.account ,
                let userInfo = UserManager.shared.account.value {
                let feeJir = BitShareCoordinator.getTransterOperation(userInfo.id.getSuffixID,
                                                                      to_user_id: accountInfo.id.getSuffixID,
                                                                      asset_id: asset.getSuffixID,
                                                                      amount: 0,
                                                                      fee_id: 0,
                                                                      fee_amount: 0,
                                                                      memo: "",
                                                                      from_memo_key: "",
                                                                      to_memo_key: "")
                
                CybexChainHelper.calculateFee(feeJir, operationID: .transfer, focusAssetId: asset) { (success, feeAmount, feeId) in
                    let realAmount = AssetHelper.setRealAmount(asset, amount: amount).stringValue
                    let feeRealAmount = AssetHelper.setRealAmount(feeId, amount: feeAmount.stringValue)
                    self.collectiton(account, feeId, asset, feeRealAmount.stringValue, realAmount,seal: seal)
                }
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }
    
    func collectiton(_ account: String ,_ feeAsset: String, _ asset: String, _ fee: String, _ amount: String, seal: Resolver<String>) {
        let assetId = asset
        let feeAssetId = feeAsset
        CybexChainHelper.blockchainParams(callback: { (blockInfo) in
            guard let fromAccount = UserManager.shared.account.value else {
                seal.fulfill("2")
                return
            }
            let jsonstr =  BitShareCoordinator.getTransaction(blockInfo.block_num.int32,
                                                              block_id: blockInfo.block_id,
                                                              expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                                              chain_id: CybexConfiguration.shared.chainID.value,
                                                              from_user_id: fromAccount.id.getSuffixID,
                                                              to_user_id: account.getSuffixID,
                                                              asset_id: assetId.getSuffixID,
                                                              receive_asset_id: assetId.getSuffixID,
                                                              amount: Int64(amount) ?? 0,
                                                              fee_id: feeAssetId.getSuffixID,
                                                              fee_amount: Int64(fee) ?? 0,
                                                              memo: "",
                                                              from_memo_key: "",
                                                              to_memo_key: "")
            
            let withdrawRequest = BroadcastTransactionRequest(response: { [weak self](data) in
                guard let self = self else {
                    seal.fulfill("2")
                    return
                }
                main {
                    self.seal = nil
                    self.account = nil
                    self.asset = nil
                    self.amount = nil
                    String(describing: data) == "<null>" ? seal.fulfill("0") : seal.fulfill("2")
                }
                }, jsonstr: jsonstr)
            CybexWebSocketService.shared.send(request: withdrawRequest)
        })
    }
    
    func openURL(_ url: String) {
        guard let safariURL = URL(string: url) else { return }
        UIApplication.shared.open(safariURL)
    }
}


