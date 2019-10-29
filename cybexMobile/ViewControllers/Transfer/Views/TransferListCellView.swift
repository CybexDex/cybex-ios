//
//  TransferListCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class TransferListCellView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var state: UILabel!

    var data: Any? {
        didSet {
            if let data = data as? TransferRecordViewModel {
                self.icon.image = data.isSend ? R.image.ic_send() : R.image.ic_income()
                self.time.text = data.time
                let addressString = data.name
                let transferAddress = AddressManager.shared.containAddressOfTransfer(addressString)

                self.address.text = transferAddress.0 == true ? transferAddress.1.first?.name : addressString
                self.state.text = data.isSend ? R.string.localizable.transfer_send.key.localized() : R.string.localizable.transfer_done.key.localized()
                self.amount.text = data.amount


                if data.isSend {
                   self.amount.textColor = ThemeManager.currentThemeIndex == 0 ? self.amount.theme1TitleColor : self.amount.theme2TitleColor
                } else {
                   self.amount.textColor = UIColor.pastelOrange
                }

                if data.outside {
                    self.alpha = 0.5
                } else {
                    self.alpha = 1
                }
            }
        }
    }

    func setup() {

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
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
