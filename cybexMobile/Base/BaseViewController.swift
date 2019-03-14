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
import CoreNFC

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func configureObserveState() {
        //    fatalError("must be realize this methods!")

    }

    func startLoading() {
        UIApplication.shared.keyWindow?.showProgress()

//        guard let hud = toast else {
//            toast = BeareadToast.showLoading(inView: self.view)
//            return
//        }
//
//        if !hud.isDescendant(of: self.view) {
//            toast = BeareadToast.showLoading(inView: self.view)
//        }
    }

    func isLoading() -> Bool {
        return UIApplication.shared.keyWindow?.iprogressHud?.isShowing() ?? false
//        return self.toast?.alpha == 1
    }

    func endLoading() {
        UIApplication.shared.keyWindow?.dismissProgress()
//        toast?.hide(true)
    }

    func endAllLoading(_ tableview: UITableView) {
        self.stopPullRefresh(tableview)
        self.stopInfiniteScrolling(tableview, haveNoMore: true)
        endLoading()
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
        Log.print("dealloc: \(self)")
    }
}

extension UIViewController {
    @objc open func leftAction(_ sender: UIButton) {
        UIApplication.shared.keyWindow?.dismissProgress()

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
        if isCanceled {
            UIApplication.shared.keyWindow?.dismissProgress()
        }
    }
}
