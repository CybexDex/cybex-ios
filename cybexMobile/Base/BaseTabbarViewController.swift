//
//  BaseTabbarViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ESTabBarController_swift

class CBTabBarView: ESTabBarItemContentView {

  public var duration = 0.3

  override init(frame: CGRect) {
    super.init(frame: frame)
    textColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
    highlightTextColor = #colorLiteral(red: 1, green: 0.6386402845, blue: 0.3285836577, alpha: 1)
    badgeColor = UIColor.red
    badgeOffset.horizontal = 12
    renderingMode = .alwaysOriginal
    titleLabel.font = UIFont.systemFont(ofSize: 9)
    insets = UIEdgeInsets(top: -2, left: 2, bottom: 2, right: 2)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func selectAnimation(animated: Bool, completion: (() -> Void)?) {
    bounceAnimation()
    completion?()
  }

    override func deselectAnimation(animated: Bool, completion: (() -> Void)?) {
        super.deselectAnimation(animated: animated, completion: completion)

    }

  override func reselectAnimation(animated: Bool, completion: (() -> Void)?) {
    bounceAnimation()
    completion?()
  }

  override func badgeChangedAnimation(animated: Bool, completion: (() -> Void)?) {
    moveAnimation()
  }

  func moveAnimation() {
    let moveAni = CAKeyframeAnimation(keyPath: "transform.translation.y")
    moveAni.values = [0.0, -8.0, 4.0, -4.0, 3.0, -2.0, 0.0]
    moveAni.duration = duration * 2
    moveAni.calculationMode = CAAnimationCalculationMode.cubic
    badgeView.layer.add(moveAni, forKey: nil)
  }

  func bounceAnimation() {
    let bounceAni = CAKeyframeAnimation.init(keyPath: "transform.scale")
    bounceAni.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
    bounceAni.duration = duration * 2
    bounceAni.calculationMode = CAAnimationCalculationMode.cubic
    imageView.layer.add(bounceAni, forKey: nil)
  }
}

class BaseTabbarViewController: ESTabBarController {

}
