//
//  Style.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftRichString

enum StyleNames:String {
  case introduce_normal
  case introduce
  case password
}


class RichStyle {
  init() {
    let style = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
      $0.lineSpacing = 8.0
    }
    Styles.register(StyleNames.introduce_normal.rawValue, style: style)
    
    let introduce_style = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
      $0.lineSpacing = 4.0
    }
    Styles.register(StyleNames.introduce.rawValue, style: introduce_style)
    
    
    passwordStyle()
  }
  
  
  func passwordStyle() {
    let normal = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14)
      $0.lineSpacing = 4
      $0.color = UIColor.steel
    }
    
    let password = Style {
      $0.font = SystemFonts.PingFangSC_Medium.font(size: 14)
      $0.color = UIColor.maincolor
    }
 
    let myGroup = StyleGroup(base: normal, ["password": password])
    Styles.register(StyleNames.password.rawValue, style: myGroup)
  }
}
