//
//  BaseViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

import SwiftTheme
import RxCocoa
import RxSwift
import SwifterSwift
import CoreNFC

class BaseViewController: UIViewController {
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

        self.view.initProgressHud()
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

    }

    deinit {
        Log.print("dealloc: \(self)")
    }
}

extension UIViewController {
    func startLoading(_ window: Bool = false) {
        if window {
            UIApplication.shared.keyWindow?.showProgress()
        } else {
            self.view.showProgress()
        }
    }

    func isLoading(_ window: Bool = false) -> Bool {
        if window {
            return UIApplication.shared.keyWindow?.iprogressHud?.isShowing() ?? false
        } else {
            return self.view.iprogressHud?.isShowing() ?? false
        }
    }

    func endLoading(_ window: Bool = false) {
        if window {
            UIApplication.shared.keyWindow?.dismissProgress()
        } else {
            self.view.dismissProgress()
        }
    }

    func endAllLoading(_ tableview: UITableView) {
        self.stopPullRefresh(tableview)
        self.stopInfiniteScrolling(tableview, haveNoMore: true)
        endLoading(false)
    }

    @objc open func leftAction(_ sender: UIButton) {
        endLoading(false)
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

    func configRightNavButton(_ image: UIImage? = nil) {
        let rightNavButton = UIButton.init(type: .custom)
        rightNavButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        rightNavButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightNavButton.setImage(image ?? #imageLiteral(resourceName: "icSettings24Px"), for: .normal)
        rightNavButton.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton)
    }

    func configRightNavButton(_ locali: String) {
        let rightNavButton = UIButton.init(type: .custom)
        rightNavButton.frame = CGRect(x: 0, y: 0, width: 58, height: 24)
        rightNavButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightNavButton.locali = locali
        rightNavButton.setTitleColor(.steel, for: .normal)
        rightNavButton.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        rightNavButton.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavButton)
    }

    @objc open func rightAction(_ sender: UIButton) {

    }


    @objc func interactivePopOver(_ isCanceled: Bool) {
        if isCanceled {
            endLoading(false)
        }
    }
}


extension UIView {
    func initProgressHud(_ dele: iProgressHUDDelegete? = nil) {
        let iprogress: iProgressHUD = iProgressHUD()
        iprogress.delegete = dele
        iprogress.iprogressStyle = .horizontal
        iprogress.indicatorStyle = .orbit
        iprogress.isShowModal = false
        iprogress.boxSize = 35
        iprogress.boxYOffset = 100

        iprogress.attachProgress(toViews: self)
    }
}

extension UIViewController: iProgressHUDDelegete {
    func onShow(view: UIView) {
    }

    func onDismiss(view: UIView) {
    }

    func onTouch(view: UIView) {
    }
}
