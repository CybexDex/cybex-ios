//
//  GrowSectionView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/22.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

class GrowSectionView: UIView {

    var cornerView: UIView?

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
        cornerView = UIView()
        cornerView?.theme1BgColor = UIColor.darkTwo
        cornerView?.theme2BgColor = UIColor.white
        self.addSubview(cornerView!)

        cornerView?.left(to: self, offset: 0)
        cornerView?.right(to: self, offset: 0)
        cornerView?.top(to: self, offset: 0)
        cornerView?.bottom(to: self, offset: 0)

        contentView = UIStackView(frame: CGRect.zero)
        contentView?.axis = .vertical
        contentView?.distribution = .fill
        contentView?.alignment = .fill
        cornerView?.addSubview(contentView!)

        contentView?.left(to: cornerView!, offset: 0)
        contentView?.right(to: cornerView!, offset: 0)
        contentView?.top(to: cornerView!, offset: 0)
        contentView?.bottom(to: cornerView!, offset: 0)

        updateHeight()
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
        return contentView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

}
