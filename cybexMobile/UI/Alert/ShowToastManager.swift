//
//  DemoManager.swift
//  Demo
//
//  Created by DKM on 2018/6/8.
//  Copyright © 2018年 DKM. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import SwiftTheme
import SwifterSwift
import Repeat

protocol Views {
    var content: Any? {get set}
}

@objc protocol ShowManagerDelegate {
    func returnUserPassword(_ sender: String)
    @objc func returnEnsureAction()
    @objc func returnEnsureImageAction()
    @objc func cancelImageAction(_ sender: CybexTextView)
    @objc func ensureWaitingAction(_ sender: CybexWaitingView)
    func returnInviteCode(_ sender: String)
}

class ShowToastManager {
    static let durationTime: TimeInterval = 0.5
    static let shared = ShowToastManager()
    var timerTime: TimeInterval = 30
    var timer: Timer?
    
    var delegate: ShowManagerDelegate?
    
    var ensureClickBlock: CommonCallback!
    
    var isShowSingleBtn: Bool? {
        didSet {
            if isShowSingleBtn == true, let textView = self.showView as? CybexTextView {
                textView.cancle.isHidden  = true
                textView.hSeparateView.isHidden = true
            }
        }
    }
    
    var showViewTop: Constraint!
    enum ShowManagerType: String {
        case alert
        case alertImage
        //        case sheet
        case sheetImage
        case text
        case waiting
    }
    enum ShowAnimationType: String {
        case none
        case upDown
        case fadeInOut
        case smallBig
    }
    
    var data: Any? {
        didSet {
            showView?.content = data
        }
    }
    
    var showView: (UIView & Views)? {
        didSet {
            
        }
    }
    
    private var superView: UIView? {
        didSet {
            self.shadowView = UIView.init(frame: UIScreen.main.bounds)
            if self.showType == ShowManagerType.sheetImage {
                self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            } else {
                self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
            superView?.addSubview(self.shadowView!)
        }
    }
    
    private var middleView: UIView? {
        didSet {
            
        }
    }
    
    private var shadowView: UIView? {
        didSet {
            
        }
    }
    
    private var animationShow: ShowAnimationType = .fadeInOut
    
    private  var showType: ShowManagerType?
    
    private init() {
        
    }
    
    // 倒计时
    func startCountDown() {
        
    }
    
    // MARK: 展示
    // 动画效果。
    func showAnimationInView(_ sender: UIView) {
        self.superView          = UIApplication.shared.keyWindow
        self.superView?.addSubview(showView!)
        showView?.content       = data
        let leading: CGFloat   = showType == .sheetImage ? 0 : 52
        let trailing: CGFloat  = showType == .sheetImage ? 0 : -52
        if animationShow == .none || animationShow == .fadeInOut || animationShow == .smallBig {
            showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: false)
            showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: false)
            showView?.centerXToSuperview(nil, offset: 0, priority: .required, isActive: true, usingSafeArea: true)
            showView?.centerYToSuperview(nil, offset: -32, priority: .required, isActive: true, usingSafeArea: true)
            self.superView?.layoutIfNeeded()
            if animationShow == .fadeInOut {
                showView?.alpha   = 0.0
                shadowView?.alpha = 0.0
                UIView.animate(withDuration: ShowToastManager.durationTime) {
                    self.showView?.alpha   = 1.0
                    self.shadowView?.alpha = 0.5
                }
            } else if animationShow == .smallBig {
                showView?.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
                UIView.animate(withDuration: ShowToastManager.durationTime,
                               delay: 0.1,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0,
                               options: UIView.AnimationOptions.curveEaseIn,
                               animations: {
                                self.showView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }, completion: { (_) in
                    
                })
            }
            return
        } else {
            let top: CGFloat  = showType == .sheetImage ? -200 : -800
            showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
            showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
            
            if showType == .sheetImage {
                showViewTop = showView?.topToSuperview(nil, offset: top, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
            } else {
                //                showView?.centerXToSuperview(nil, offset: 0,  priority: .required, isActive: true, usingSafeArea: true)
                showViewTop = showView?.centerYToSuperview(nil, offset: top, priority: .required, isActive: true, usingSafeArea: true)
            }
            self.superView?.layoutIfNeeded()
            if showType == .sheetImage {
                showViewTop?.constant = 20
            } else {
                showViewTop?.constant = -32
            }
            UIView.animate(withDuration: ShowToastManager.durationTime) {
                self.superView?.layoutIfNeeded()
            }
        }
    }
    
    // MARK: 隐藏
    // 动画效果。
    func hide() {
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        self.showView = nil
        self.shadowView = nil
        self.data = nil
    }
    
    func hide(_ time: TimeInterval) {
        if animationShow == .none || animationShow == .smallBig {
            SwifterSwift.delay(milliseconds: time * 1000) {
                self.showView?.removeFromSuperview()
                self.shadowView?.removeFromSuperview()
                self.showView = nil
                self.shadowView = nil
                self.data = nil
                self.isShowSingleBtn = nil
            }
        } else if animationShow == .fadeInOut {
            UIView.animate(withDuration: ShowToastManager.durationTime, delay: time, options: .curveLinear, animations: {
                self.showView?.alpha   = 0.0
                self.shadowView?.alpha = 0.0
            }) { (_) in
                self.showView?.removeFromSuperview()
                self.shadowView?.removeFromSuperview()
                self.showView = nil
                self.shadowView = nil
                self.data = nil
                self.isShowSingleBtn = nil
            }
        } else if animationShow == .upDown {
            showViewTop.constant = showType == .sheetImage ? -200 : -800
            UIView.animate(withDuration: ShowToastManager.durationTime, delay: time, options: .curveLinear, animations: {
                self.superView?.layoutIfNeeded()
            }) { (_) in
                self.showView?.removeFromSuperview()
                self.shadowView?.removeFromSuperview()
                self.showView = nil
                self.shadowView = nil
                self.data = nil
                self.isShowSingleBtn = nil
            }
        }
    }
    
    func setUp(title: String, message: String, animationType: ShowAnimationType, showType: ShowManagerType = .alert) {
        self.data          = ["title": title, "message": message]
        self.animationShow = animationType
        self.showType      = showType
        
        self.setupAlert()
    }
    
    func setUp(titleImage: String, message: String, animationType: ShowAnimationType, showType: ShowManagerType) {
        self.data = ["titleImage": titleImage, "message": message]
        self.animationShow = animationType
        self.showType = showType
        if showType == .alertImage {
            self.setupAlertImage()
        } else if showType == .sheetImage {
            self.setupSheetImage()
        }
    }
    
    func setUp(title: String, contentView: (UIView&Views), animationType: ShowAnimationType, middleType: CybexTextView.TextViewType = .normal) {
        self.animationShow  = animationType
        self.showType       = ShowManagerType.alertImage
        self.setupText(contentView, title: title, cybexTextViewType: middleType)
    }
    
    func setUp(titleImage: String, contentView: (UIView&Views), animationType: ShowAnimationType) {
        self.animationShow  = animationType
        self.showType       = ShowManagerType.alertImage
        self.setupTextImage(contentView, titleImage: titleImage)
    }
    
    func setUp(_ title: String, content: String, time: Int, animationType: ShowAnimationType) {
        self.animationShow = animationType
        self.showType = ShowManagerType.waiting
        self.setupWaiting(title, content: content, time: time)
    }
    
    fileprivate func setupAlert() {
        let alertView            = CybexAlertView(frame: CGRect.zero)
        alertView.isShowImage    = false
        showView                 = alertView
    }
    
    fileprivate func setupAlertImage() {
        let alertView            = CybexAlertView(frame: CGRect.zero)
        alertView.isShowImage    = true
        showView                 = alertView
    }
    
    fileprivate func setupSheetImage() {
        let sheetView = CybexActionView(frame: .zero)
        showView     = sheetView
    }
    
    fileprivate func setupText(_ sender: (UIView&Views), title: String, cybexTextViewType: CybexTextView.TextViewType) {
        let textView = CybexTextView(frame: .zero)
        textView.delegate = self
        textView.middleView = sender
        textView.title.text = title
        textView.viewType = cybexTextViewType
        if cybexTextViewType == .time, let textMiddleView = textView.middleView as? CybexPasswordView {
            textMiddleView.textField.isSecureTextEntry = false
            textMiddleView.textField.placeholder = ""
        }
        if cybexTextViewType == .time, self.timerTime != 30, self.timerTime != 0 {
            textView.ensure.isEnabled = false
            textView.ensure.setTitle(String(self.timerTime), for: UIControl.State.normal)
        }
        showView = textView
    }
    
    fileprivate func setupTextImage(_ sender: (UIView&Views), titleImage: String) {
        let textView = CybexTextView(frame: .zero)
        textView.delegate = self
        textView.middleView = sender
        textView.title.isHidden = true
        textView.titleImageView.isHidden = false
        textView.titleImageView.image = UIImage(named: titleImage)
        showView = textView
    }
    
    fileprivate func setupWaiting(_ title: String, content: String, time: Int) {
        let waitView = CybexWaitingView(frame: .zero)
        waitView.titleLabel.text = title
        waitView.contentLabel.text = content
        waitView.time = time
        waitView.delegate = self
        showView = waitView
    }
    
    func updateCybexTextViewType(_ sender: CybexTextView) {
        sender.ensure.isEnabled = false
        sender.ensure.setTitle(self.timerTime.string(digits: 0, roundingMode: .down) + R.string.localizable.transfer_unit_second.key.localized(), for: .normal)
        self.timerTime = 30
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeTimerTimeAction), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    @objc func changeTimerTimeAction() {
        if self.timerTime <= 0 {
            self.timer?.invalidate()
            self.timer = nil
        } else {
            self.timerTime -= 1
        }
        
        guard let textview = self.showView as? CybexTextView, textview.viewType == .time else { return }
        
        if self.timerTime <= 0 {
            textview.ensure.setTitle(R.string.localizable.alert_ensure.key.localized(), for: .normal)
            textview.ensure.isEnabled = true
        } else {
            textview.ensure.setTitle(self.timerTime.string(digits: 0, roundingMode: .down) + R.string.localizable.transfer_unit_second.key.localized(), for: .normal)
        }
    }
}

extension ShowToastManager: CybexTextViewDelegate {
    func returnPassword(_ password: String, sender: CybexTextView) {
        if let type = sender.viewType, type == .time {
            self.updateCybexTextViewType(sender)
            self.delegate?.returnInviteCode(password)
        } else {
            self.delegate?.returnUserPassword(password)
        }
    }
    
    func clickCancle(_ sender: CybexTextView) {
        self.hide(0)
        self.delegate?.cancelImageAction(sender)
    }
    
    func returnEnsureAction() {
        self.hide(0)
        self.delegate?.returnEnsureAction()
        if self.isShowSingleBtn != nil {
            self.ensureClickBlock()
        }
    }
    
    func returnEnsureImageAction() {
        self.hide(0)
        self.delegate?.returnEnsureImageAction()
    }
}

extension ShowToastManager: CybexWaitingProtocol {
    func waitingEnsureAction(sender: CybexWaitingView) {
        self.delegate?.ensureWaitingAction(sender)
    }
}
