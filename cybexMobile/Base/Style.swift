//
//  Style.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftRichString

class RichStyle {
  init() {
    let style = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
      $0.lineSpacing = 8.0
    }
    Styles.register("introduce_normal", style: style)
    
    let introduce_style = Style {
      $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
      $0.color = UIColor.steel
      $0.lineSpacing = 4.0
    }
    Styles.register("introduce", style: introduce_style)
    
  }  
}
