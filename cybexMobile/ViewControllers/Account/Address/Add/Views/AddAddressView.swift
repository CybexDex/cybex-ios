//
//  AddAddressView.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

enum image_state: Int {
    case normal = 0
    case Loading
    case Fail
    case Success
}

class AddAddressView: UIView {

    @IBOutlet weak var asset: RechargeItemView!
    @IBOutlet weak var address: AddressItemView!
    @IBOutlet weak var mark: RechargeItemView!
    @IBOutlet weak var memo: AddressItemView!
    @IBOutlet weak var addBtn: Button!

    @IBOutlet weak var assetShadowView: CornerAndShadowView!

    fileprivate var activityIndicator: UIActivityIndicatorView?
    var data: Any? {
        didSet {
            if let address = data as? WithdrawAddress {
                self.asset.content.text = app_data.assetInfo[address.currency]?.symbol.filterJade
                self.address.content.text = address.address
                self.memo.content.text = address.memo
            } else if let address = data as? TransferAddress {
                self.address.content.text = address.address
                self.mark.content.text = address.name
            }
        }
    }

    var address_state: image_state = .normal {
        didSet {
            switch self.address_state {
            case .normal:
                self.address.icon.isHidden = true
                break
            case .Loading:
                self.address.icon.isHidden = false
                self.address.icon.setBackgroundImage(nil, for: .normal)
                self.startAnimation()
                break
            case .Fail:
                self.address.icon.isHidden = false
                self.stop()
                self.address.icon.setBackgroundImage(R.image.ic_close_24_px(), for: .normal)
                break
            case .Success:
                self.address.icon.isHidden = false
                self.stop()
                self.address.icon.setBackgroundImage(R.image.check_complete(), for: .normal)
                break
            }
        }
    }

    func startAnimation() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.address.icon.width, height: self.address.icon.height))
        self.activityIndicator?.style = .gray
        self.activityIndicator?.center = CGPoint(x: self.address.icon.width * 0.5, y: self.address.icon.height * 0.5)
        self.address.icon.addSubview(self.activityIndicator!)
        self.activityIndicator?.startAnimating()
    }

    func stop() {
        self.activityIndicator?.stopAnimating()
    }

    fileprivate func setup() {
        updateHeight()

        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.address.content, queue: nil) { [weak self](_) in
            guard let `self` = self else {return}
            self.updateHeight()
        }

        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.memo.content, queue: nil) { [weak self](_) in
            guard let `self` = self else {return}
            self.updateHeight()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView?.bottom ?? 0
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
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        insertSubview(view, at: 0)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
