//
//  SettingViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift
import SwiftTheme
import SwiftyUserDefaults
import SwifterSwift
import XLActionController

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var environment: NormalCellView!
    
    @IBOutlet weak var help: NormalCellView!
    @IBOutlet weak var language: NormalCellView!
    @IBOutlet weak var frequency: NormalCellView!
    @IBOutlet weak var version: NormalCellView!
    @IBOutlet weak var theme: NormalCellView!
    
    @IBOutlet weak var logoutView: Button!
    var coordinator: (SettingCoordinatorProtocol & SettingStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizedText = R.string.localizable.navSetting.key.localizedContainer()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        setupUI()
        setupNotification()
        setupEvent()
        if !UserManager.shared.isLoginIn {
            self.logoutView.isHidden = true
        }
        self.logoutView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            UserManager.shared.logout()
            self.coordinator?.dismiss()
        }).disposed(by: disposeBag)
    }
    
    func setupUI() {
//        #if DEBUG
//        self.environment.isHidden = false
//        #endif
        language.contentLocali =  R.string.localizable.setting_language.key
        version.content.text = Bundle.main.version
        theme.contentLocali = ThemeManager.currentThemeIndex == 0 ? R.string.localizable.dark.key : R.string.localizable.light.key
        frequency.contentLocali = UserManager.shared.frequencyType.description()
    }
    
    func setupEvent() {
        let itemsView = [language, frequency, version, help, theme, environment]
        
        for itemView in itemsView {
            itemView?.rx.tapGesture().when(.ended).asObservable().subscribe(onNext: { [weak self](tap) in
                guard let `self` = self else { return }
                if let view = tap.view as? NormalCellView {
                    self.clickCellView(view)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }
    }
    
    func clickCellView(_ sender: NormalCellView) {
        
        if sender == language {
            self.coordinator?.openSettingDetail(type: .language)
        } else if sender == frequency {
            self.chooseRefreshStyle()
        } else if sender == version {
            handlerUpdateVersion({
                self.endLoading()
            }, showNoUpdate: true)
        } else if sender == help {
            self.coordinator?.openHelpWebView()
        } else if sender == theme {
            self.coordinator?.openSettingDetail(type: .theme)
        } else if sender == environment {
            self.coordinator?.changeEnveronment({ isTest in
                self.showToastBox(true, message: isTest == true ? "当前为测试环境" : "当前为正式环境")
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let `self` = self else { return }
            
            let color = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: color), for: .default)
        })
    }
    
    override func configureObserveState() {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
    }
}

extension SettingViewController {
    func chooseRefreshStyle() {
        let actionController = PeriscopeActionController()
        actionController.selectedIndex = IndexPath(row: UserManager.shared.frequencyType.rawValue, section: 0)
        actionController.addAction(Action(R.string.localizable.frequency_normal.key.localized(), style: .destructive, handler: {[weak self] _ in
            guard let `self` = self else {return}
            UserManager.shared.frequencyType = .normal
            self.frequency.contentLocali = UserManager.shared.frequencyType.description()
        }))
        
        actionController.addAction(Action(R.string.localizable.frequency_time.key.localized(), style: .destructive, handler: { [weak self]_ in
            guard let `self` = self else {return}
            
            UserManager.shared.frequencyType = .time
            self.frequency.contentLocali = UserManager.shared.frequencyType.description()
            
        }))
        
        actionController.addAction(Action(R.string.localizable.frequency_wifi.key.localized(), style: .destructive, handler: { [weak self]_ in
            guard let `self` = self else {return}
            UserManager.shared.frequencyType = .wiFi
            self.frequency.contentLocali = UserManager.shared.frequencyType.description()
        }))
        
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: { _ in
        }))
        
        present(actionController, animated: true, completion: nil)
    }
}
