//
//  AddressItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

@IBDesignable
class AddressItemView: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var lineView: UIView!
    
    @IBInspectable var title : String = "" {
        didSet{
            name.localized_text = title.localizedContainer()
        }
    }
    
    @IBInspectable var textplaceholder : String = "" {
        didSet{
            content.toolbarPlaceholder = textplaceholder
        }
    }
    
    @IBInspectable var isShowLineView : Bool = true {
        didSet {
            self.lineView.isHidden = !isShowLineView
        }
    }
    
    
    @IBInspectable var maxNumberOfLines : Int = Int.max {
        didSet {
            self.content.textContainer.maximumNumberOfLines = maxNumberOfLines
        }
    }
    
    var data: Any? {
        didSet {
            
        }
    }
    
    fileprivate func setup() {
        updateHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric,height: dynamicHeight())
    }
    
    fileprivate func updateHeight() {
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
