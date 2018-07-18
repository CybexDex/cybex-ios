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

protocol Views {
  var content : Any? {get set}
}

@objc protocol ShowManagerDelegate {
  func returnUserPassword(_ sender : String)
  @objc func returnEnsureAction()
}

class ShowToastManager {
  
  static let durationTime : TimeInterval = 0.5
  static let shared = ShowToastManager()
  
  var delegate:ShowManagerDelegate?

  var ensureClickBlock : CommonCallback!
  
  var isShowSingleBtn : Bool? {
    didSet{
      if isShowSingleBtn == true,let textView = self.showView as? CybexTextView{
        textView.cancle.isHidden  = true
        textView.ensureRight.constant = (textView.width - textView.ensure.width) * 0.5
      }
    }
  }
  
  var showViewTop : Constraint!
  enum ShowManagerType : String{
    case alert
    case alert_image
    //        case sheet
    case sheet_image
    case text
  }
  enum ShowAnimationType : String{
    case none
    case up_down
    case fadeIn_Out
    case small_big
  }
  
  var data : Any?{
    didSet{
      showView?.content = data
    }
  }
  
  
  var showView : (UIView & Views)?{
    didSet{
      
    }
  }
  
  private var superView : UIView?{
    didSet{
      self.shadowView = UIView.init(frame: UIScreen.main.bounds)
      if self.showType == ShowManagerType.sheet_image{
        self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
      }else{
        self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      }
      superView?.addSubview(self.shadowView!)
    }
  }
  
  private var middleView : UIView?{
    didSet{
      
    }
  }
  
  private var shadowView : UIView?{
    didSet{
      
    }
  }
  
  
  private var animationShow : ShowAnimationType = .fadeIn_Out
  
  private  var showType : ShowManagerType?
  
  private init(){
    
  }
  
  // MARK: 展示
  // 动画效果。
  func showAnimationInView(_ sender: UIView){
    self.superView          = UIApplication.shared.keyWindow
    self.superView?.addSubview(showView!)
    showView?.content       = data
    let leading : CGFloat   = showType == .sheet_image ? 0 : 52
    let trailing : CGFloat  = showType == .sheet_image ? 0 : 52
    if animationShow == .none || animationShow == .fadeIn_Out || animationShow == .small_big{
      showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      showView?.centerXToSuperview(nil, offset: 0, priority: .required, isActive: true, usingSafeArea: true)
      showView?.centerYToSuperview(nil, offset: -32, priority: .required, isActive: true, usingSafeArea: true)
      self.superView?.layoutIfNeeded()
      if animationShow == .fadeIn_Out{
        showView?.alpha   = 0.0
        shadowView?.alpha = 0.0
        UIView.animate(withDuration: ShowToastManager.durationTime) {
          self.showView?.alpha   = 1.0
          self.shadowView?.alpha = 0.5
        }
      }else if animationShow == .small_big{
        showView?.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: ShowToastManager.durationTime, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
          self.showView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }, completion:{ (isFinished) in
          
        })
      }
      return
    }else{
      let top     : CGFloat  = showType == .sheet_image ? -200 : -800
      showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      
      if showType == .sheet_image{
        showViewTop = showView?.topToSuperview(nil, offset: top, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      }else{
        showView?.centerXToSuperview(nil, offset: 0,  priority: .required, isActive: true, usingSafeArea: true)
        showViewTop = showView?.centerYToSuperview(nil, offset: top, priority: .required, isActive: true, usingSafeArea: true)
      }
      self.superView?.layoutIfNeeded()
      if showType == .sheet_image{
        showViewTop?.constant = 20
      }else{
        showViewTop?.constant = -32
      }
      UIView.animate(withDuration: ShowToastManager.durationTime) {
        self.superView?.layoutIfNeeded()
      }
    }
  }
  
  // MARK: 隐藏
  // 动画效果。
  func hide(){
    self.showView?.removeFromSuperview()
    self.shadowView?.removeFromSuperview()
    self.showView = nil
    self.shadowView = nil
    self.data = nil
  }
  
  func hide(_ time : TimeInterval){
    if animationShow == .none || animationShow == .small_big{
      SwifterSwift.delay(milliseconds: time * 1000) {
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        self.showView = nil
        self.shadowView = nil
        self.data = nil
        self.isShowSingleBtn = nil
      }
    }else if animationShow == .fadeIn_Out {
      UIView.animate(withDuration: ShowToastManager.durationTime, delay: time, options: .curveLinear, animations: {
        self.showView?.alpha   = 0.0
        self.shadowView?.alpha = 0.0
      }) { (isFinished) in
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        self.showView = nil
        self.shadowView = nil
        self.data = nil
        self.isShowSingleBtn = nil
      }
    }else if animationShow == .up_down{
      showViewTop.constant = showType == .sheet_image ? -200 : -800
      UIView.animate(withDuration: ShowToastManager.durationTime, delay: time, options: .curveLinear, animations: {
        self.superView?.layoutIfNeeded()
      }) { (isFinished) in
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        self.showView = nil
        self.shadowView = nil
        self.data = nil
        self.isShowSingleBtn = nil
      }
    }
  }
  
  func setUp(title:String,message:String,animationType:ShowAnimationType,showType:ShowManagerType = .alert){
    self.data          = ["title":title,"message":message]
    self.animationShow = animationType
    self.showType      = showType
    
    self.setupAlert()
  }
  
  
  func setUp(title_image:String,message:String,animationType:ShowAnimationType,showType:ShowManagerType){
    self.data          = ["title_image":title_image,"message":message]
    self.animationShow = animationType
    self.showType      = showType
    if showType == .alert_image{
      self.setupAlertImage()
    }else if showType == .sheet_image{
      self.setupSheetImage()
    }
  }
  
  
  func setUp(title:String,contentView:(UIView&Views),animationType:ShowAnimationType){
    self.animationShow  = animationType
    self.showType       = ShowManagerType.alert_image
    self.setupText(contentView,title: title)
  }
  
  
  fileprivate func setupAlert(){
    let alertView            = CybexAlertView(frame: CGRect.zero)
    alertView.isShowImage    = false
    showView                 = alertView
  }
  
  fileprivate func setupAlertImage(){
    let alertView            = CybexAlertView(frame: CGRect.zero)
    alertView.isShowImage    = true
    showView                 = alertView
  }
  
  fileprivate func setupSheetImage(){
    let sheetView = CybexActionView(frame: .zero)
    showView     = sheetView
  }
  
  fileprivate func setupText(_ sender:(UIView&Views),title:String){
    let textView = CybexTextView(frame: .zero)
    textView.delegate = self
    textView.middleView = sender
    textView.title.text = title
    showView     = textView
  }
}

extension ShowToastManager : CybexTextViewDelegate{
  func returnPassword(_ password:String){
    self.delegate?.returnUserPassword(password)    
  }
  func clickCancle(){
    self.hide(0)
  }
  func returnEnsureAction(){
    self.hide(0)
    self.delegate?.returnEnsureAction()
    if self.isShowSingleBtn != nil{
      self.ensureClickBlock()
    }
  }
}

