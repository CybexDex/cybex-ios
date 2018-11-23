//
//  rechargeView.swift
//  Demo
//
//  Created by DKM on 2018/6/6.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import SwiftTheme

enum RechargeType: Int {
    case none = 0
    case address
    case photo
    case all
}

@IBDesignable
class RechargeItemView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: ImageTextField!
    @IBOutlet weak var btn: UIButton!

    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!

    @IBOutlet weak var addressStateImageView: UIImageView!

    fileprivate var activityIndicator: UIActivityIndicatorView?

    @IBInspectable var name: String = "" {
        didSet {
            title.localizedText = name.localizedContainer()
        }
    }

    @IBInspectable var SOURCETYPE: Int = 0 {
        didSet {
            btnType = RechargeType(rawValue: SOURCETYPE)
        }
    }

    @IBInspectable var textplaceholder: String = "" {
        didSet {
            content.localizedText = textplaceholder.localizedContainer()
//            content.placeholder = self.content.placeholder!
            content.setPlaceHolderTextColor(UIColor.steel50)
        }
    }

    @IBInspectable var isShowLineView: Bool = false {
        didSet {
            bottomLineView.isHidden = !isShowLineView
        }
    }

    var btnType: RechargeType? {
        didSet {
            switch btnType! {
            case .none:
                btn.isHidden = true
                content.isEnabled = false
            case .address:
                btn.isHidden = false
                leftImageView.isHidden = false
                leftView.isHidden = false
                leftImageView.image = R.image.ic_address_16_px()
            default:
                break
            }
        }
    }

    var addressState: ImageState = .normal {
        didSet {
            if self.btnType != .address {
                return
            }
            switch addressState {
            case .normal:
                self.addressStateImageView.isHidden = true
                break
            case .loading:
                self.addressStateImageView.isHidden = false
                self.addressStateImageView.image = nil
                self.startAnimation()
                break
            case .fail:
                self.addressStateImageView.isHidden = false
                self.stop()
                self.addressStateImageView.image = R.image.ic_close_24_px()
                break
            case .success:
                self.addressStateImageView.isHidden = false
                self.stop()
                self.addressStateImageView.image = R.image.check_complete()
                break
            }
        }
    }

    func startAnimation() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.addressStateImageView.width, height: self.addressStateImageView.height))
        self.activityIndicator?.style = .gray
        self.activityIndicator?.center = CGPoint(x: self.addressStateImageView.width * 0.5, y: self.addressStateImageView.height * 0.5)
        self.addressStateImageView.addSubview(self.activityIndicator!)
        self.activityIndicator?.startAnimating()
    }

    func stop() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator = nil
    }

    func setupUI() {
        self.content.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
        setupUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.layer.cornerRadius = 4.0
        view.clipsToBounds = true
        addSubview(view)

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
