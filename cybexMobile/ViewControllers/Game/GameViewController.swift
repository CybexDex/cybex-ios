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

class GameViewController: BaseViewController {
    
    let jsObjectName = "Potral"
    var coordinator: (GameCoordinatorProtocol & GameStateManagerProtocol)?
    private(set) var context: GameContext?
    var object: GameModel!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.webView.scalesPageToFit = true
    }
    
    func setupData() {
        if let url = Bundle.main.url(forResource: "game", withExtension: "html") {
            self.setupLoadUrl(url)
        }
    }
    
    func setupLoadUrl(_ url: URL) {
        let request = NSURLRequest(url: url)
        self.webView.loadRequest(request as URLRequest)
    }
    
    func setupEvent() {
    }
    
    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let `self` = self else { return }
            
            if let context = context as? GameContext {
                self.context = context
            }
            
        }).disposed(by: disposeBag)
        
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
            self.endLoading()
            
            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))
                
            case .loading(let reason):
                if reason == .initialRefresh {
                    //                    self.startLoading()
                }
                
            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))
                
            case .loadMore(let page):
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))
                
            case .noMore:
                //                self.stopInfiniteScrolling(self.tableView, haveNoMore: true)
                break
                
            case .noData:
                //                self.view.showNoData(<#title#>, icon: <#imageName#>)
                break
                
            case .normal(_):
                //                self.view.hiddenNoData()
                //
                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break
                
            case .error(_, _):
                //                self.showToastBox(false, message: error.localizedDescription)
                
                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break
            }
        }).disposed(by: disposeBag)
    }
}

extension GameViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext else {
            return
        }
        object = GameModel()
        object.delegate = self
        object.viewController = self
        object.context = context
        context.setObject(object, forKeyedSubscript: self.jsObjectName as NSCopying & NSObjectProtocol)
    }
}

extension GameViewController {
    override func passwordDetecting() {
        self.startLoading()
    }
    
    override func passwordPassed(_ passed: Bool) {
        self.endLoading()
        if !passed {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
        else {
            self.object.loginCallBack()
        }
    }
}

extension GameViewController: GameModelCallBackDelegate {
    func lockAccount() {
        main {
            self.showPasswordBox()        
        }
    }
    
    func openURL(_ url: String) {
        main {
            self.setupLoadUrl(URL(string: url)!)
        }
    }
}

