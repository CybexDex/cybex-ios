//
//  CybexWebViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import SwiftyUserDefaults
import Localize_Swift

class CybexWebViewController: BaseWebViewController {
    
    enum web_type: Int {
        case help = 0
        case kyc
        case whitelist
        case project_website
        case whitepaper
    }
    
    var coordinator: (CybexWebCoordinatorProtocol & CybexWebStateManagerProtocol)?
    
    var vc_type: web_type = .help
    
    override func viewDidLoad() {
        if vc_type == .help {
            let url = Defaults[.theme] == 0 ?AppConfiguration.HELP_NIGHT_URL + Localize.currentLanguage() : AppConfiguration.HELP_LIGHT_URL + Localize.currentLanguage()
            self.url = URL(string: url)
        }
        super.viewDidLoad()
        
        setupUI()
        setupEvent()
       
    }
    
    override func leftAction(_ sender: UIButton) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
        else {
            super.leftAction(sender)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        switch self.vc_type {
        case .help:
            self.title = R.string.localizable.setting_help.key.localized()
        case .kyc:
            break
        default:
            break
        }
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in
            guard let `self` = self else { return }
            self.setURL()
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            self.setURL()
        }
    }
    
    func setURL() {
        if ThemeManager.currentThemeIndex == 0 {
            self.url = URL(string: AppConfiguration.HELP_NIGHT_URL + Localize.currentLanguage())
        } else {
            self.url = URL(string: AppConfiguration.FAQ_LIGHT_THEME + Localize.currentLanguage())
        }
    }
    
    override func configureObserveState() {
        coordinator?.state.pageState.asObservable().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

