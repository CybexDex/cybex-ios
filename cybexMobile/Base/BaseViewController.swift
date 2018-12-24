//
//  BaseViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import BeareadToast_swift

import SwiftTheme
import RxCocoa
import RxSwift
import SwifterSwift

class BaseViewController: UIViewController {
    weak var toast: BeareadToast?
    var rightNavButton: UIButton?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }

    required init?(coder aDswicoder: NSCoder) {
        super.init(coder: aDswicoder)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentThemeIndex == 0 ? .lightContent : .default
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        self.extendedLayoutIncludesOpaqueBars = true

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .never
        }

        self.view.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]

        configureObserveState()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        let color = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: color), for: .default)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func configureObserveState() {
        //    fatalError("must be realize this methods!")

    }

    func startLoading() {
        guard let hud = toast else {
            toast = BeareadToast.showLoading(inView: self.view)
            return
        }

        if !hud.isDescendant(of: self.view) {
            toast = BeareadToast.showLoading(inView: self.view)
        }
    }

    func isLoading() -> Bool {
        return self.toast?.alpha == 1
    }

    func endLoading() {
        toast?.hide(true)
    }

    func configRightNavButton(_ image: UIImage? = nil) {
        rightNavButton = UIButton.init(type: .custom)
        rightNavButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        rightNavButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightNavButton?.setImage(image ?? #imageLiteral(resourceName: "icSettings24Px"), for: .normal)
        rightNavButton?.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton?.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton!)
    }

    func configRightNavButton(_ locali: String) {
        rightNavButton = UIButton.init(type: .custom)
        rightNavButton?.frame = CGRect(x: 0, y: 0, width: 58, height: 24)
        rightNavButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightNavButton?.locali = locali
        rightNavButton?.setTitleColor(.steel, for: .normal)
        rightNavButton?.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton?.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton!)
    }

    @objc open func rightAction(_ sender: UIButton) {

    }

    deinit {
        print("dealloc: \(self)")
    }
}

extension UIViewController {
    @objc open func leftAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func configLeftNavigationButton(_ image: UIImage?) {
        let leftNavButton = UIButton.init(type: .custom)
        leftNavButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        leftNavButton.setImage(image ?? R.image.ic_back_24_px(), for: .normal)
        leftNavButton.addTarget(self, action: #selector(leftAction(_:)), for: .touchUpInside)
        leftNavButton.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftNavButton)
    }

    @objc func interactivePopOver(_ isCanceled: Bool) {

    }
}

extension UIViewController: ShowManagerDelegate {
    func showPasswordBox(_ title: String = R.string.localizable.withdraw_unlock_wallet.key.localized(), middleType: CybexTextView.TextViewType = .normal) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }

        SwifterSwift.delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .smallBig, middleType: middleType)
            ShowToastManager.shared.delegate = self
            ShowToastManager.shared.showAnimationInView(self.view)
        }
    }

    func showToastBox(_ success: Bool, message: String, manager: ShowToastManager = ShowToastManager.shared) {
        if manager.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        SwifterSwift.delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(titleImage: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name,
                                          message: message,
                                          animationType: .smallBig, showType: .alertImage)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.hide(2.0)
        }
    }
    
    func showToast(message: String, manager: ShowToastManager = ShowToastManager.shared) {
        if manager.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        SwifterSwift.delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(message: message,
                                          animationType: .smallBig, showType: .alertImage)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.hide(2.0)
        }
    }

    func showConfirm(_ title: String, attributes: [NSAttributedString]?, setup: (([StyleLabel]) -> Void)? = nil) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        SwifterSwift.delay(milliseconds: 100) {
            let subView = CybexShowTitleView(frame: .zero)
            subView.title.locali = ""
            subView.contentLable.locali = "openedorder_ensure_message"
//            setup?(subView.labels)

            ShowToastManager.shared.setUp(title: title, contentView: subView, animationType: .smallBig, middleType: .normal)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func showConfirmImage(_ titleImage: String, title: String, content: String) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        SwifterSwift.delay(milliseconds: 100) {
            let subView = CybexShowTitleView(frame: .zero)
            subView.title.locali = title
            subView.contentLable.locali = content
            ShowToastManager.shared.setUp(titleImage: titleImage, contentView: subView, animationType: .smallBig)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func showWaiting(_ title: String, content: String, time: Int) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        SwifterSwift.delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(title, content: content, time: time, animationType: ShowToastManager.ShowAnimationType.smallBig)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func returnEnsureAction() {

    }
    func returnEnsureImageAction() {

    }
    func cancelImageAction(_ sender: CybexTextView) {

    }

    @objc func passwordPassed(_ passed: Bool) {

    }

    @objc func passwordDetecting() {

    }

    func returnUserPassword(_ sender: String) {
        ShowToastManager.shared.hide()
        passwordDetecting()

        if let name = UserManager.shared.name.value {
            UserManager.shared.unlock(name, password: sender) {[weak self] (success, _) in
                self?.passwordPassed(success)
            }
        }
    }

    func ensureWaitingAction(_ sender: CybexWaitingView) {

    }

    func returnInviteCode(_ sender: String) {

    }
}
