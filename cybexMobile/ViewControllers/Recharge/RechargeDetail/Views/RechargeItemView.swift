//
//  rechargeView.swift
//  Demo
//
//  Created by DKM on 2018/6/6.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import SwiftTheme

enum Recharge_Type:Int{
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
    
    fileprivate var activityIndicator : UIActivityIndicatorView?

    @IBInspectable var name : String = "" {
        didSet{
            title.localized_text = name.localizedContainer()
        }
    }
    
    @IBInspectable var SOURCE_TYPE : Int = 0{
        didSet{
            btn_type = Recharge_Type(rawValue: SOURCE_TYPE)
        }
    }
    
    @IBInspectable var textplaceholder : String = "" {
        didSet{
            content.locali = textplaceholder
            content.attributedPlaceholder = NSAttributedString(string:self.content.placeholder!,
                                                               attributes:[NSAttributedStringKey.foregroundColor: UIColor.steel50])
        }
    }
    
    @IBInspectable var isShowLineView : Bool = false {
        didSet {
            bottomLineView.isHidden = !isShowLineView
        }
    }
    
    var btn_type : Recharge_Type? {
        didSet{
            switch btn_type! {
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
    
    var address_state : image_state? {
        didSet {
            if self.btn_type != .address {
                return
            }
            if let state = self.address_state {
                switch state {
                case .none:
                    self.addressStateImageView.isHidden = true
                    break
                case .Loading:
                    self.addressStateImageView.isHidden = false
                    self.addressStateImageView.image = nil
                    self.startAnimation()
                    break
                case .Fail:
                    self.addressStateImageView.isHidden = false
                    self.stop()
                    self.addressStateImageView.image = R.image.ic_close_24_px()
                    break
                case .Success:
                    self.addressStateImageView.isHidden = false
                    self.stop()
                    self.addressStateImageView.image = R.image.check_complete()
                    break
                }
            }
        }
    }
    
    func startAnimation() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.addressStateImageView.width, height: self.addressStateImageView.height))
        self.activityIndicator?.activityIndicatorViewStyle = .gray
        self.activityIndicator?.center = CGPoint(x: self.addressStateImageView.width * 0.5, y: self.addressStateImageView.height * 0.5)
        self.addressStateImageView.addSubview(self.activityIndicator!);
        self.activityIndicator?.startAnimating()
    }
    
    func stop() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator = nil
    }
    
    
    func setupUI(){
        self.content.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
    }
    
    fileprivate func updateHeight(){
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize.init(width:UIViewNoIntrinsicMetric,height:dynamicHeight())
    }
    
    fileprivate func dynamicHeight() -> CGFloat{
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
    
    func loadFromXIB(){
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.layer.cornerRadius = 4.0
        view.clipsToBounds = true
        addSubview(view)
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
}
