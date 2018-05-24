//
//  LabelView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Foundation

class GradientLabelView: UIView {
  
  let gradientLayer: LinearGradientLayer = {
    let gradientLayer = LinearGradientLayer()
    gradientLayer.colors = [UIColor.steel30.cgColor, UIColor.steel11.cgColor]
    return gradientLayer
  }()
  
  func setup(){
    gradientLayer.frame = self.bounds
    self.layer.addSublayer(gradientLayer)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
    gradientLayer.frame = self.bounds
  }

}
