//
//  BeareadToast.swift
//  BeareadToast
//
//  Created by Archy on 2017/12/19.
//  Copyright © 2017年 Archy. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct ToastMacros {
    static let isIphoneX: Bool = UIScreen.main.bounds.height == 812
    static let bottomHeight: CGFloat = ToastMacros.isIphoneX ? 83 : 49
    static let topHeight: CGFloat = 200
}

public enum ToastAnimationType {
    case fade, zoom, slide
}

public enum ToastPosition {
    case top, center, bottom
}

public enum ToastType {
    case normal, success, error, loading
}

@objc public protocol BeareadToastDelegate {
    @objc optional func toastWillShow(toast: BeareadToast, inView: UIView)
    @objc optional func toastDidShow(toast: BeareadToast, inView: UIView)
    @objc optional func toastWillHide(toast: BeareadToast, inView: UIView)
    @objc optional func toastDidHide(toast: BeareadToast, inView: UIView)
}

public class BeareadToast: UIView {
    
    public private(set) var parentView: UIView?
    public var delegate: BeareadToastDelegate?
    public var position: ToastPosition = .top
    public var type: ToastType = .normal {
        didSet {
            self.isHaveLeft = true
            if type == .error {
                contentView.backgroundColor = #colorLiteral(red: 1, green: 0.2702886103, blue: 0.243625315, alpha: 1)
                imgToast.image = UIImage.init(named: "icon_toast_failed", in: self.resource, compatibleWith: nil)
                imgToast.isHidden = false
                loadingView.isHidden = true
            }
            else if type == .success {
                contentView.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6235294118, blue: 1, alpha: 1)
                imgToast.image = UIImage.init(named: "icon_toast_succeed", in: self.resource, compatibleWith: nil)
                imgToast.isHidden = false
                loadingView.isHidden = true
            }
            else if type == .loading {
                contentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                text = "Loading..."
                lblToast.text = text
                imgToast.isHidden = true
                loadingView.isHidden = false
            }
            else if type == .normal {
                contentView.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.7764705882, blue: 0.3019607843, alpha: 1)
                imgToast.isHidden = true
                loadingView.isHidden = true
                isHaveLeft = false
            }
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }
    public lazy var animator: BeareadToastAnimator = {
        let ani = BeareadToastAnimator.init(toast: self)
        ani.animationType = .slide
        return ani
    }()
    public var text: String?
    public lazy var contentView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 15, y: 10, width: UIScreen.main.bounds.size.width - 30, height: 44))
        view.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6235294118, blue: 1, alpha: 1)
        view.layer.cornerRadius = 22;
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.05
        view.alpha = 0
        return view
    }()
    public var isRemoveFromSuperViewWhenHide: Bool = true
    
    fileprivate var hideDelayTimer: Timer?
    
    fileprivate lazy var imgToast: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 15, y: 10, width: 29, height: 24))
        return img
    }()
    
    fileprivate lazy var lblToast: UILabel = {
        let lbl = UILabel.init(frame: CGRect.init(x: 50, y: 12, width: 0, height: 20))
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    fileprivate lazy var loadingView: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView.init(frame: CGRect.init(x: 6, y: 3, width: 38, height: 38))
        loading.style = .gray
        loading.color = .white
        loading.hidesWhenStopped = true
        return loading
    }()
    
    fileprivate var isHaveLeft: Bool = false
    
    fileprivate lazy var resource: Bundle = {
        let bundle = Bundle(for: self.classForCoder)
        let url = bundle.resourceURL?.appendingPathComponent("BeareadToast.bundle")
        let brBundle = Bundle(url: url!)!
        return brBundle
    }()
    
    public init?(view: UIView?) {
        guard let parentView = view else {
            return nil
        }
        self.parentView = parentView
        super.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        parentView.addSubview(self)
        defaultConfig()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.parentView = nil
        super.init(coder: aDecoder)
        return nil
    }
    
    deinit {
        if hideDelayTimer != nil && (hideDelayTimer?.isValid)! {
            hideDelayTimer?.invalidate()
            hideDelayTimer = nil
        } else {
            hideDelayTimer = nil
        }
        parentView = nil
        removeNotifications()
    }
    
    fileprivate func didShow() {
        if let dele = self.delegate {
            dele.toastDidShow!(toast: self, inView: parentView!)
        }
    }
    
    fileprivate func willShow() {
        if let dele = self.delegate {
            dele.toastWillShow!(toast: self, inView: parentView!)
        }
    }
    
    fileprivate func didHide() {
        if let dele = self.delegate {
            dele.toastDidHide!(toast: self, inView: parentView!)
        }
        loadingView.stopAnimating()
        hideDelayTimer?.invalidate()
        alpha = 0
        if isRemoveFromSuperViewWhenHide {
            self.removeFromSuperview()
        }
    }
    
    fileprivate func willHide() {
        if let dele = self.delegate {
            dele.toastWillHide!(toast: self, inView: parentView!)
        }
    }
    
    public func show(_ animated: Bool) {
        setNeedsDisplay()
        
        hideDelayTimer?.invalidate()
        willShow()
        
        if animated {
            self.animator.show(completion: {[weak self] (finished) in
                guard let `self` = self else { return }
                self.didShow()
            })
        } else {
            alpha = 1
            contentView.alpha = 1
            didShow()
        }
    }
    
    @objc public func hide(_ animated: Bool) {
        willHide()
        
        if animated {
            self.animator.hide(completion: {[weak self] (finished) in
                guard let `self` = self else { return }
                self.didHide()
            })
        } else {
            alpha = 0
            contentView.alpha = 0
            didHide()
        }
    }
    
    public func hide(_ animated: Bool, after delay: TimeInterval) {
        if #available(iOS 10.0, *) {
            let timer = Timer.init(timeInterval: delay, repeats: false) { (timer) in
                self.hide(animated)
            }
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        } else {
            let timer = Timer.init(timeInterval: delay, target: self, selector: #selector(timerAction(_:)), userInfo: animated, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    @objc fileprivate func timerAction(_ timer: Timer) {
        let animated = timer.userInfo as! Bool
        hide(animated)
    }
    
    fileprivate func defaultConfig() {
        contentView.addSubview(imgToast)
        contentView.addSubview(loadingView)
        contentView.addSubview(lblToast)
        addSubview(contentView)
    }
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    @objc fileprivate func statusBarOrientationDidChange() {
        setNeedsDisplay()
        layoutIfNeeded()
    }
    
    fileprivate func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        switch position {
        case .top: frame = CGRect.init(x: 0, y: ToastMacros.topHeight, width: UIScreen.main.bounds.size.width, height: 64)
        case .center: frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height / 2.0 - 32, width: UIScreen.main.bounds.size.width, height: 64)
        case .bottom: frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height - ToastMacros.bottomHeight - 64, width: UIScreen.main.bounds.width, height: 64)
        }
        var textWidth: CGFloat = 0
        var contentWidth: CGFloat = 0
        if isHaveLeft {
            let labelWidth = lblToast.sizeThatFits(CGSize.init(width: UIScreen.main.bounds.size.width - 95, height: 20)).width
            textWidth = (labelWidth > UIScreen.main.bounds.size.width - 95) ? UIScreen.main.bounds.size.width - 95 : labelWidth
            lblToast.frame = CGRect.init(x: 50, y: 12, width: textWidth, height: 20)
            contentWidth = textWidth + 65
        } else {
            let labelWidth = lblToast.sizeThatFits(CGSize.init(width: UIScreen.main.bounds.size.width - 60, height: 20)).width
            textWidth = (labelWidth > UIScreen.main.bounds.size.width - 60) ? UIScreen.main.bounds.size.width - 60 : labelWidth
            lblToast.frame = CGRect.init(x: 15, y: 12, width: textWidth, height: 20)
            contentWidth = textWidth + 30
        }
        contentView.frame = CGRect.init(x: (UIScreen.main.bounds.size.width - contentWidth) / 2.0, y: 10, width: contentWidth, height: 44.0)
    }
}

extension BeareadToast {
    public func showSucceed(_ text: String) {
        showSucceed(text, hide: 0)
    }
    
    public func showSucceed(_ text: String, hide delay: TimeInterval) {
        lblToast.text = text
        type = .success
        show(true)
        if delay > 0 {
            hide(true, after: delay)
        }
    }
    
    public func showError(_ text: String) {
        showError(text, hide: 0)
    }
    
    public func showError(_ text: String, hide delay: TimeInterval) {
        lblToast.text = text
        type = .error
        show(true)
        if delay > 0 {
            hide(true, after: delay)
        }
    }
    
    public func showText(_ text: String) {
        showText(text, hide: 0)
    }
    
    public func showText(_ text: String, hide delay: TimeInterval) {
        lblToast.text = text
        type = .normal
        show(true)
        if delay > 0 {
            hide(true, after: delay)
        }
    }
    
    public func showLoading() {
        showLoading(after: 0)
    }
    
    public func hideLoading() {
        loadingView.stopAnimating()
        hide(true)
    }
    
    public func showLoading(after delay: TimeInterval) {
        type = .loading
        show(true)
        loadingView.startAnimating()
        if delay > 0 {
            hide(true, after: delay)
        }
    }
    
    public static func showSucceed(text: String, inView: UIView) -> BeareadToast? {
        return showSucceed(text: text, inView: inView, hide: 0)
    }
    
    public static func showSucceed(text: String, inView: UIView, hide delay: TimeInterval) -> BeareadToast? {
        let toast = BeareadToast.init(view: inView)
        toast?.showSucceed(text, hide: delay)
        return toast
    }
    
    public static func showError(text: String, inView: UIView) -> BeareadToast? {
        return showError(text: text, inView: inView, hide: 0)
    }
    
    public static func showError(text: String, inView: UIView, hide delay: TimeInterval) -> BeareadToast? {
        let toast = BeareadToast.init(view: inView)
        toast?.showError(text, hide: delay)
        return toast
    }

    public static func showText(text: String, inView: UIView) -> BeareadToast? {
        return showText(text: text, inView: inView, hide: 0)
    }
    
    public static func showText(text: String, inView: UIView, hide delay: TimeInterval) -> BeareadToast? {
        let toast = BeareadToast.init(view: inView)
        toast?.showText(text, hide: delay)
        return toast
    }

    public static func showLoading(inView: UIView) -> BeareadToast? {
        return showLoading(inView: inView, hide: 0)
    }
    
    public static func showLoading(inView: UIView, hide delay: TimeInterval) -> BeareadToast? {
        let toast = BeareadToast.init(view: inView)
        toast?.showLoading(after: delay)
        return toast
    }

}

extension BeareadToast {
    
    public static func hideIn(_ view: UIView) -> Bool {
        var result = false
        if let toast = toastIn(view) {
            toast.isRemoveFromSuperViewWhenHide = true
            toast.hide(true)
            result = true
        }
        return result
    }
    
    public static func hideAllIn(_ view: UIView) -> Bool {
        let arr = allToastIn(view)
        var result = false
        for toast in arr {
            toast.isRemoveFromSuperViewWhenHide = true
            toast.hide(true)
            result = true
        }
        return result
    }
    
    public static func toastIn(_ view: UIView) -> BeareadToast? {
        for sub in view.subviews {
            if sub is BeareadToast {
                return sub as? BeareadToast
            }
        }
        return nil
    }
    
    public static func allToastIn(_ view: UIView) -> [BeareadToast] {
        var arr: [BeareadToast] = []
        for sub in view.subviews {
            if sub is BeareadToast {
                arr.append(sub as! BeareadToast)
            }
        }
        return arr
    }
}
