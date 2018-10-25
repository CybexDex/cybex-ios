//
//  LockupProgressView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

@IBDesignable
class LockupProgressView: UIView {

    @IBInspectable
    var progress: Double = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    //  控制渐进的色彩的方向
    // 0 是水平。1是垂直
    @IBInspectable
    var direction: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var colors: [CGColor]? {
        didSet {

        }
    }

    @IBInspectable
    var beginColor: UIColor = UIColor.clear {
        didSet {

        }
    }
    @IBInspectable
    var endColor: UIColor = UIColor.clear {
        didSet {

        }
    }

    @IBInspectable
    var space: CGFloat = 2 {
        didSet {

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if let sublayers = self.layer.sublayers {
            for  layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        let gradient = createGradientLayer()
        self.layer.addSublayer(gradient)
        gradient.mask = createMaskLayer(rect)
    }

    func createGradientLayer() -> CAGradientLayer {
        let beginColor = self.beginColor.cgColor
        let endColor = self.endColor.cgColor
        let colorArr = [beginColor, endColor]
        let gradient = CAGradientLayer()
        if let colors = self.colors {
            gradient.colors = colors
        } else {
            gradient.colors = colorArr
        }
        let x = self.direction == 0 ? 1 : 0
        let y = self.direction == 1 ? 1 : 0
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: x, y: y)
        gradient.opacity = 1.0
        gradient.frame = self.bounds
        return gradient
    }

    func createMaskLayer(_ rect: CGRect) -> CALayer {
        let maskLayer        = CALayer()
        maskLayer.frame      = CGRect(x: space, y: space, width: CGFloat(self.progress) * (rect.width - space * 2), height: rect.height - space * 2)
        maskLayer.cornerRadius = maskLayer.frame.height * 0.5
        maskLayer.backgroundColor = UIColor.black.cgColor
        return maskLayer
    }
}
