//
//  GrowSectionView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/22.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

class GrowSectionView: CornerAndShadowView {
    
    var contentView: UIStackView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        contentView = UIStackView(frame: CGRect.zero)
        contentView?.axis = .vertical
        contentView?.distribution = .fill
        contentView?.alignment = .fill
        self.addSubview(contentView!)
        
        contentView?.left(to: self, offset: 0)
        contentView?.right(to: self, offset: 0)
        contentView?.top(to: self, offset: 0)
        contentView?.bottom(to: self, offset: 0)
        
        updateHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
    }
    
    func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func dynamicHeight() -> CGFloat {
        return contentView!.bottom
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

}
