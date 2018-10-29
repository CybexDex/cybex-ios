//
//  OpenedOrdersStatesView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
@IBDesignable
class OpenedOrdersStatesView: UIView {
    lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.cornerRadius = 2.0
        label.font = UIFont.systemFont(ofSize: 9.0)
        label.clipsToBounds = true
        return label
    }()
    @IBInspectable
    var openedStatus: Int = 0 {
        didSet {
            switch openedStatus {
            case 0:
                label.backgroundColor = buyColor
                label.text      = "BUY"
                break
            case 1:
                label.backgroundColor = sellColor
                label.text      = "SELL"
                break
            default:
                break
            }
        }
    }
    @IBInspectable
    var sellColor: UIColor = UIColor.reddish {
        didSet {
            label.backgroundColor = sellColor
        }
    }
    @IBInspectable
    var buyColor: UIColor = UIColor.turtleGreen {
        didSet {
            label.backgroundColor = buyColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        self.addSubview(label)
    }
}
