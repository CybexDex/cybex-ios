//
//  CornerAndShadowView.swift
//  EOS
//
//  Created by zhusongyu on 2018/7/16.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class CornerAndShadowView: UIView {

    @IBOutlet weak var cornerView: UIView!

    @IBInspectable
    var newCornerRadius: CGFloat = 4 {
        didSet {
            cornerView.cornerRadius = newCornerRadius
            self.subviews.forEach { [weak self](subView) in
                guard let self = self else { return }
                if subView.shadowOpacity == 0 {
                    subView.cornerRadius = self.cornerView.cornerRadius
                }
            }
        }
    }

    @IBInspectable
    var newShadowRadius: CGFloat = 4 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.shadowRadius = newShadowRadius
                }
            }
        }
    }

    @IBInspectable
    var newShadowColor: UIColor = UIColor.dark20 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.shadowColor = newShadowColor
                }
            }
        }
    }

    @IBInspectable
    var newTheme1ShadowColor: UIColor = UIColor.dark20 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.theme1ShadowColor = newTheme1ShadowColor
                }
            }
        }
    }

    @IBInspectable
    var newTheme2ShadowColor: UIColor = UIColor.dark20 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.theme2ShadowColor = newTheme2ShadowColor
                }
            }
        }
    }

    @IBInspectable
    var newShadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.shadowOffset = newShadowOffset
                }
            }
        }
    }

    @IBInspectable
    var newShadowOpcity: Float = 1 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    subView.shadowOpacity = newShadowOpcity
                }
            }
        }
    }

    @IBInspectable
    var newSpread: CGFloat = 0 {
        didSet {
            self.subviews.forEach { (subView) in
                if subView.shadowOpacity == 1 {
                    if subView.spread == 0 {
                        subView.layer.shadowPath = nil
                    } else {
                        let rect = subView.bounds.insetBy(dx: -newSpread, dy: -newSpread)
                        subView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
                    }
                }
            }
        }
    }

    func setup() {
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()

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
        let bundle = Bundle(for: CornerAndShadowView.self)
        let nibName = String(describing: CornerAndShadowView.self)
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        self.insertSubview(view, at: 0)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
