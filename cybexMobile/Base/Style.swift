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
    case withdraw_introduce
    case alertContent
}

enum LineViewStyleNames:String {
  case normal_name
  case normal_content
  case transfer_confirm
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
    
    let with_style = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
      $0.lineSpacing = 4.0
    }
    Styles.register(StyleNames.withdraw_introduce.rawValue, style: with_style)
    
    passwordStyle()
    alertDetailStyle()
    initLineViewStyle()
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
  
  func alertDetailStyle(){
    let base = Style{
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
    }
    
    let name = Style{
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
    }
    
    let content_buy = Style{
      $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
      $0.color = UIColor.turtleGreen
    }
    
    let content_sell = Style{
      $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
      $0.color = UIColor.reddish
    }
    
    
    let content_dark = Style{
      $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
      $0.color = UIColor.white
    }
    
    let content_light = Style{
      $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
      $0.color = UIColor.darkTwo
    }
    
    
    let myGroup = StyleGroup(base: base, ["name":name,"content_dark":content_dark,"content_light":content_light,"content_sell":content_sell,"content_buy":content_buy])
    StylesManager.shared.register(StyleNames.alertContent.rawValue, style: myGroup)
  }
  
  func initLineViewStyle(){
    let name_style = Style{
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 16.0)
    }
    Styles.register(LineViewStyleNames.normal_name.rawValue, style: name_style)
    
    let content_style = Style{
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
    }
    Styles.register(LineViewStyleNames.normal_content.rawValue, style: content_style)
    
    let confirm_style = Style{
      $0.font = SystemFonts.PingFangSC_Semibold.font(size: 16.0)
    }
    Styles.register(LineViewStyleNames.transfer_confirm.rawValue, style: confirm_style)
    
  }
}



