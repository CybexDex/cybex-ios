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
    
    var coordinator: (CybexWebCoordinatorProtocol & CybexWebStateManagerProtocol)?
    
    override func viewDidLoad() {
        let url = Defaults[.theme] == 0 ?AppConfiguration.HELP_NIGHT_URL + Localize.currentLanguage() : AppConfiguration.HELP_LIGHT_URL + Localize.currentLanguage()
        self.url = URL(string: url)
        super.viewDidLoad()
        
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.title = R.string.localizable.setting_help.key.localized()
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

