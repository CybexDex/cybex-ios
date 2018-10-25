//
//  Button.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import RxCocoa

@IBDesignable
class Button: UIView {
    @IBOutlet weak var button: UIButton!

    @IBInspectable var locali: String? {
        didSet {
            self.button.locali = locali!
            updateView()
        }
    }

    var rx_isEnable: BehaviorRelay<Bool> = BehaviorRelay(value: false) {
        didSet {
            self.isEnable = rx_isEnable.value
        }
    }

    @IBInspectable var isEnable: Bool = false {
        didSet {
            updateView()
        }
    }

    var colors: [CGColor]? {
        didSet {
            self.gradientLayer.colors = colors
        }
    }

    var gradientLayer: LinearGradientLayer = {
        let gradientLayer = LinearGradientLayer()
        gradientLayer.colors = [UIColor.peach.cgColor, UIColor.maincolor.cgColor]
        return gradientLayer
    }()

    func updateView() {
        if isEnable {
            gradientLayer.isHidden = false
            self.button.isUserInteractionEnabled = false
            self.button.backgroundColor = .clear
            self.button.setTitleColor(.white, for: UIControl.State.normal)
            self.button.setTitleColor(.white, for: UIControl.State.disabled)
        } else {
            gradientLayer.isHidden = true
            self.button.isUserInteractionEnabled = true
            self.button.backgroundColor = .steel30
            self.button.setTitleColor(.white30, for: UIControl.State.normal)
        }
    }

    fileprivate func setup() {
        gradientLayer.frame = self.bounds
        self.button.isUserInteractionEnabled = true
        self.button.layer.addSublayer(gradientLayer)

        updateView()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        gradientLayer.frame = self.bounds
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
