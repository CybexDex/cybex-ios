//
//  NoticeBoardView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/17.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import RxCocoa
import SwiftTheme

class NoticeBoardView: UIView {
    enum Event: String {
        case confirm
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var confirm: Button!
    
    var data: Any? {
        didSet {
            if let password = data as? String {
                let str = R.string.localizable.registerConfirm.key.localized().replacingOccurrences(of: "<password></password>", with: "<password>\(password)</password>")
                
                self.textView.styledText = str
            }
        }
    }
    
    fileprivate func setup() {
        self.confirm.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            self.next?.sendEventWith(Event.confirm.rawValue, userinfo: ["data": self.data ?? []])
            
        }).disposed(by: disposeBag)
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
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
