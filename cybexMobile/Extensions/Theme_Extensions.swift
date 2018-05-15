//
//  Theme_Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

extension UILabel {
  @IBInspectable
  var theme1TitleColor:UIColor {
    set {
      if let theme2 = self.store["label_theme2"] as? String {
        theme_textColor = [newValue.hexString(true), theme2]
      }
      else {
        self.store["label_theme1"] = newValue.hexString(true)
      }
    }
    
    get {
      return theme_textColor?.value() as! UIColor
    }
  }
  
  var themeTitleColor:UIColor {
    return theme_textColor?.value() as! UIColor
  }
  
  @IBInspectable
  var theme2TitleColor:UIColor {
    set {
      if let theme1 = self.store["label_theme1"] as? String {
        theme_textColor = [theme1, newValue.hexString(true)]
      }
      else {
        self.store["label_theme2"] = newValue.hexString(true)
      }
    }
    
    get {
      return theme_textColor?.value() as! UIColor
    }
  }
}

extension UIView {
  @IBInspectable
  var theme1BgColor:UIColor {
    set {
      if let theme2 = self.store["bg_theme2"] as? String {
        theme_backgroundColor = [newValue.hexString(true), theme2]
      }
      else {
        self.store["bg_theme1"] = newValue.hexString(true)
      }
    }
    
    get {
      return theme_backgroundColor?.value() as! UIColor
    }
  }
  
  @IBInspectable
  var theme2BgColor:UIColor {
    set {
      if let theme1 = self.store["bg_theme1"] as? String {
        theme_backgroundColor = [theme1, newValue.hexString(true)]
      }
      else {
        self.store["bg_theme2"] = newValue.hexString(true)
      }
    }
    
    get {
      return theme_backgroundColor?.value() as! UIColor
    }
  }
  
  var themeBgColor:UIColor {
    return theme_backgroundColor?.value() as! UIColor
  }
}
