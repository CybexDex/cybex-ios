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

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var environment: NormalCellView!
    
    @IBOutlet weak var help: NormalCellView!
    @IBOutlet weak var eNotesUnlockType: NormalCellView!
    @IBOutlet weak var eNotesCloudPasswordSet: NormalCellView!
    @IBOutlet weak var language: NormalCellView!
    @IBOutlet weak var frequency: NormalCellView!
    @IBOutlet weak var locktime: NormalCellView!
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
        if !UserManager.shared.logined {
            self.logoutView.isHidden = true
        }
        self.logoutView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            
            UserManager.shared.logout()
            self.coordinator?.dismiss()
        }).disposed(by: disposeBag)
    }
    
    func setupUI() {
        #if DEBUG
        self.environment.isHidden = false
        #else
        self.view.rx.tapGesture(numberOfTouchesRequired: 2, numberOfTapsRequired: 5).when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.environment.isHidden = false
        }).disposed(by: disposeBag)
        #endif

        if UserManager.shared.loginType != .nfc {
            eNotesUnlockType.isHidden = true
            eNotesCloudPasswordSet.isHidden = true
        } else {
            eNotesUnlockType.isHidden = false
            eNotesCloudPasswordSet.isHidden = false
            eNotesUnlockType.contentLocali = UserManager.shared.unlockType.description()

            refreshCloudPasswordStatus()
        }

        language.contentLocali = R.string.localizable.setting_language.key
        version.content.text = Bundle.main.version
        theme.contentLocali = ThemeManager.currentThemeIndex == 0 ? R.string.localizable.dark.key : R.string.localizable.light.key
        frequency.contentLocali = UserManager.shared.frequencyType.description()
        locktime.content.text =  UserManager.shared.lockTime.description()
    }

    func refreshCloudPasswordStatus() {
        if UserManager.shared.loginType == .nfc {
            if !UserManager.shared.checkExistCloudPassword() {
                eNotesCloudPasswordSet.contentLocali = R.string.localizable.enotes_cloudpassword_unset.key
                eNotesCloudPasswordSet.rightIcon.isHidden = false
            } else {
                eNotesCloudPasswordSet.contentLocali = R.string.localizable.enotes_cloudpassword_haveset.key
                eNotesCloudPasswordSet.rightIcon.isHidden = true
            }
        }
    }
    
    func setupEvent() {
        var itemsView: [NormalCellView] = []

        if UserManager.shared.loginType != .nfc {
            itemsView = [language, frequency, locktime, version, help, theme, environment]
        } else {
            itemsView = [eNotesUnlockType, eNotesCloudPasswordSet, language, frequency, locktime, version, help, theme, environment]
        }

        for itemView in itemsView {
            itemView.rx.tapGesture().when(.ended).asObservable().subscribe(onNext: { [weak self](tap) in
                guard let self = self else { return }
                if let view = tap.view as? NormalCellView {
                    self.clickCellView(view)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }
    }
    
    func clickCellView(_ sender: NormalCellView) {
        if sender == eNotesUnlockType {
            if UserManager.shared.checkExistCloudPassword() {
                chooseUnlockType()
            }
        } else if sender == eNotesCloudPasswordSet {
            if !UserManager.shared.checkExistCloudPassword() {
                pushCloudPasswordViewController(nil)
            }
        } else if sender == language {
            self.coordinator?.openSettingDetail(type: .language)
        } else if sender == frequency {
            self.chooseRefreshStyle()
        } else if sender == locktime {
            self.chooseLockTime()
        } else if sender == version {
            handlerUpdateVersion({
                self.endLoading()
            }, showNoUpdate: true)
        } else if sender == help {
            self.coordinator?.openHelpWebView()
        } else if sender == theme {
            self.coordinator?.openSettingDetail(type: .theme)
        } else if sender == environment {
            self.switchEnv()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCloudPasswordStatus()
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let self = self else { return }
            
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
        let actions = [
            Action(R.string.localizable.frequency_normal.key.localized(), style: .destructive, handler: {[weak self] _ in
                guard let self = self else {return}
                UserManager.shared.frequencyType = .normal
                self.frequency.contentLocali = UserManager.shared.frequencyType.description()
            }),
            Action(R.string.localizable.frequency_time.key.localized(), style: .destructive, handler: { [weak self]_ in
                guard let self = self else {return}

                UserManager.shared.frequencyType = .time
                self.frequency.contentLocali = UserManager.shared.frequencyType.description()

            }),
            Action(R.string.localizable.frequency_wifi.key.localized(), style: .destructive, handler: { [weak self]_ in
                guard let self = self else {return}
                UserManager.shared.frequencyType = .wiFi
                self.frequency.contentLocali = UserManager.shared.frequencyType.description()
            })
        ]
        openSelectedActionViewController(UserManager.shared.frequencyType.rawValue, actions: actions)
    }

    func switchEnv() {
        let actions = AppEnv.allCases.map { (env) -> Action<String> in
            return Action(env.rawValue, style: .destructive, handler: {[weak self] _ in
                guard let self = self else {return}

                self.showToastBox(true, message: "当前为\(env.rawValue)环境")
                Defaults[\.environment] = env.rawValue
                self.coordinator?.changeEnveronment()
            })
        }

        openSelectedActionViewController(AppEnv.current.index, actions: actions)
    }

    func chooseUnlockType() {
        let actions = [
            Action(R.string.localizable.enotes_unlock_type_0.key.localized(), style: .destructive, handler: {[weak self] _ in
                guard let self = self else {return}
                UserManager.shared.unlockType = UserManager.UnlockType.nfc
                self.eNotesUnlockType.contentLocali = UserManager.UnlockType.nfc.description()
            }),
            Action(R.string.localizable.enotes_unlock_type_1.key.localized(), style: .destructive, handler: { [weak self]_ in
                guard let self = self else {return}
                UserManager.shared.unlockType = UserManager.UnlockType.cloudPassword
                self.eNotesUnlockType.contentLocali = UserManager.UnlockType.cloudPassword.description()
            })
        ]
        openSelectedActionViewController(UserManager.shared.unlockType.rawValue - 1, actions: actions)
    }

    func chooseLockTime() {
        let actions = [
            Action(UserManager.LockTime.low.description(), style: .destructive, handler: {[weak self] _ in
                guard let self = self else {return}
                UserManager.shared.lockTime = .low
                self.locktime.content.text = UserManager.shared.lockTime.description()
            }),

            Action(UserManager.LockTime.middle.description(), style: .destructive, handler: { [weak self]_ in
                guard let self = self else {return}
                UserManager.shared.lockTime = .middle
                self.locktime.content.text = UserManager.shared.lockTime.description()
            }),
            
            Action(UserManager.LockTime.high.description(), style: .destructive, handler: { [weak self]_ in
                guard let self = self else {return}
                UserManager.shared.lockTime = .high
                self.locktime.content.text = UserManager.shared.lockTime.description()
            })
        ]

        for (index, type) in UserManager.LockTime.allCases.enumerated() {
            if type == UserManager.shared.lockTime {
                openSelectedActionViewController(index - 1, actions: actions)
                return
            }
        }

    }
}
