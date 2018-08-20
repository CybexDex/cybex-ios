//
//  BaseViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import BeareadToast

import SwiftTheme
import RxCocoa
import RxSwift
import SwifterSwift

class BaseViewController: UIViewController {
    
    lazy var errorSubscriber: BlockSubscriber<String?> = BlockSubscriber {[weak self] s in
        guard let `self` = self else { return }
        
    }
    
    lazy var loadingSubscriber: BlockSubscriber<Bool> = BlockSubscriber {[weak self] s in
        guard let `self` = self else { return }
    }
    
    weak var toast: BeareadToast?
    var table:UITableView?
    var leftNavButton: UIButton?
    var rightNavButton: UIButton?
    var isNavBarShadowHidden: Bool = false {
        didSet {
            if isNavBarShadowHidden {
                navigationController?.navigationBar.shadowImage = UIImage()
            } else {
                navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDswicoder: NSCoder) {
        super.init(coder: aDswicoder)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func configureObserveState() {
        //    fatalError("must be realize this methods!")
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    func changeNavBar(isUserInteractionEnabled: Bool) {
        self.navigationController?.navigationBar.rx.observe(Bool.self, "isUserInteractionEnabled").subscribe(onNext: { [weak self] (enabled) in
            guard let `self` = self else { return }
            
            if self.navigationController?.visibleViewController != self {
                return
            }
            //      print("Change Change Change")
            if isUserInteractionEnabled {
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.subviews.forEach({ (view) in
                    view.isUserInteractionEnabled = true
                })
            } else {
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                self.navigationController?.navigationBar.subviews.forEach({ (view) in
                    view.isUserInteractionEnabled = false
                })
            }
            
        }).disposed(by: disposeBag)
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
    
    func endLoading(_ after:TimeInterval) {
        toast?.hide(true, after: after)
    }
    
    func configLeftNavButton(_ image:UIImage?) {
        leftNavButton = UIButton.init(type: .custom)
        leftNavButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        leftNavButton?.setImage(image ?? #imageLiteral(resourceName: "ic_view_list_24px"), for: .normal)
        leftNavButton?.addTarget(self, action: #selector(leftAction(_:)), for: .touchUpInside)
        leftNavButton?.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftNavButton!)
    }
    
    func configRightNavButton(_ image:UIImage? = nil) {
        rightNavButton = UIButton.init(type: .custom)
        rightNavButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        rightNavButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightNavButton?.setImage(image ?? #imageLiteral(resourceName: "icSettings24Px"), for: .normal)
        rightNavButton?.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton?.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton!)
    }
    
    func configRightNavButton(_ locali:String) {
        rightNavButton = UIButton.init(type: .custom)
        rightNavButton?.frame = CGRect(x: 0, y: 0, width: 58, height: 24)
        rightNavButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightNavButton?.locali = locali
        rightNavButton?.setTitleColor(.steel, for: .normal)
        rightNavButton?.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton?.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton!)
    }
    
    @objc open func leftAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc open func rightAction(_ sender: UIButton) {
        
    }
    
    deinit {
        print("dealloc: \(self)")
    }
}

extension UIViewController : ShowManagerDelegate {
    
    
    func showPasswordBox(_ title:String = R.string.localizable.withdraw_unlock_wallet.key.localized()){
        if ShowToastManager.shared.showView != nil {
            return
        }
        ShowToastManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .small_big)
        ShowToastManager.shared.delegate = self

        ShowToastManager.shared.showAnimationInView(self.view)
    }
    
    func showToastBox(_ success:Bool, message:String) {
        if ShowToastManager.shared.showView != nil {
            return
        }
        ShowToastManager.shared.setUp(title_image: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name, message: message, animationType: .small_big, showType: .alert_image)
        ShowToastManager.shared.showAnimationInView(self.view)
        ShowToastManager.shared.hide(2.0)
    }
    
    func showTopToastBox(_ success:Bool, message:String) {
        if ShowToastManager.shared.showView != nil {
            return
        }
        ShowToastManager.shared.setUp(title_image: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name, message: message, animationType: ShowToastManager.ShowAnimationType.up_down, showType: ShowToastManager.ShowManagerType.sheet_image)
        ShowToastManager.shared.showAnimationInView(self.view)
        ShowToastManager.shared.hide(2.0)
    }
    
    func showConfirm(_ title:String, attributes:[NSAttributedString]?, setup: (([StyleLabel]) -> Void)? = nil) {
        if ShowToastManager.shared.showView != nil {
            return
        }
        let subView = StyleContentView(frame: .zero)
        subView.data = attributes
        setup?(subView.labels)
        
        ShowToastManager.shared.setUp(title: title, contentView: subView, animationType: .small_big)
        ShowToastManager.shared.showAnimationInView(self.view)
        ShowToastManager.shared.delegate = self
    }
    
    
    func showConfirmImage(_ title_image:String, title:String,content:String) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
//            return
        }
        SwifterSwift.delay(milliseconds: 100) {
            let subView = CybexShowTitleView(frame: .zero)
            subView.title.locali = title
            subView.contentLable.locali = content
            ShowToastManager.shared.setUp(title_image: title_image, contentView: subView, animationType: .small_big)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }
    
    func returnEnsureAction() {
        
    }
    func returnEnsureImageAction() {
        
    }
    
    
    @objc func passwordPassed(_ passed:Bool) {
        
    }
    @objc func passwordDetecting() {
        
    }
    
    func returnUserPassword(_ sender : String){
        ShowToastManager.shared.hide()
        passwordDetecting()
        
        if let name = UserManager.shared.name.value {
            UserManager.shared.unlock(name, password: sender) {[weak self] (success, _) in
                self?.passwordPassed(success)
            }
        }
    }
}
