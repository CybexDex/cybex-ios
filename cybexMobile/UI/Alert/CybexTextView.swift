
//
//  CybexTextView.swift
//  Demo
//
//  Created by DKM on 2018/6/6.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import TinyConstraints



class CybexTextView: UIView {
    
    var middleView : (UIView&Views)? {
        didSet{
            contentView.addSubview(middleView!)
            middleView?.leading(to: contentView,offset:20)
            middleView?.trailing(to: contentView,offset:-20)
            middleView?.top(to:contentView,offset:20)
            middleView?.bottom(to:contentView,offset:0)
        }
    }
    
    var data : Any? {
        didSet{
            self.middleView?.content  = data
            updateHeight()
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cancle: UIButton!
    @IBOutlet weak var ensure: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBAction func cancleClick(_ sender: Any) {
    }
    @IBAction func ensureClick(_ sender: Any) {
    }
    
    
    
    override var  intrinsicContentSize: CGSize{
        return CGSize.init(width: UIViewNoIntrinsicMetric, height: dynamicHeight())
    }
    
    
    fileprivate func dynamicHeight() -> CGFloat{
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }
    
    
    fileprivate func updateHeight(){
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadFromXIB()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
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

extension CybexTextView : Views{
    var content : Any? {
        get{
            return self.data
        }
        set {
            self.data = newValue
        }
    }
}
