//
//  GrowContentView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/20.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import TinyConstraints

protocol GrowContentViewDataSource {
    func numberOfSection(_ contentView: GrowContentView) -> NSInteger
    func numberOfRowWithSection(_ contentView: GrowContentView,section: NSInteger) -> NSInteger
    func marginOfContentView(_ contentView: GrowContentView) -> CGFloat
    func heightWithSectionHeader(_ contentView: GrowContentView,section: NSInteger) -> CGFloat
    func cornerRadiusOfSection(_ contentView: GrowContentView,section: NSInteger) -> CGFloat
    func shadowSettingOfSection(_ contentView: GrowContentView,section: NSInteger) -> (color: UIColor,offset: CGSize,radius: CGFloat)
    func viewOfIndexpath(_ contentView: GrowContentView,indexpath: NSIndexPath) -> (view: UIView,key: String)
}

@IBDesignable
class GrowContentView: UIView {
    
    static let baseSectionHeadTag = 2999
    
    var contentView: UIStackView?
    
    var stackViews: [GrowSectionView] = []
    
    var rowViewDic: NSMutableDictionary = [:]
    
    var datasource: GrowContentViewDataSource? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        guard let datasource = self.datasource else {
            return
        }
        let sectionNumber = datasource.numberOfSection(self)
        
        for section in 0..<sectionNumber {
            let sectionHeight = datasource.heightWithSectionHeader(self, section: section)
            setSectionHeight(datasource.heightWithSectionHeader(self, section: section), section: section)
            
            let margin: CGFloat = self.datasource!.marginOfContentView(self)
            let sectionView = self.sectionView(section, headerHeight: sectionHeight)
            contentView?.addArrangedSubview(sectionView)
            sectionView.left(to: contentView!, offset: margin)
            sectionView.right(to: contentView!, offset: -margin)
            
            stackViews.append(sectionView)
            updateSection(section)
        }
        contentView?.updateConstraintsIfNeeded()
    }
    
    fileprivate func sectionView(_ section: NSInteger, headerHeight: CGFloat) -> GrowSectionView {
        let sectionView = GrowSectionView()
        sectionView.backgroundColor = UIColor.white
        if let radius = self.datasource?.cornerRadiusOfSection(self, section: section) {
            sectionView.newCornerRadius = radius
        }
        
        if let shadowSetting = self.datasource?.shadowSettingOfSection(self, section: section) {
            sectionView.newShadowColor = shadowSetting.color
            sectionView.newShadowOffset = shadowSetting.offset
            sectionView.newShadowRadius = shadowSetting.radius
        }
        return sectionView
    }
    
    fileprivate func updateSection(_ section: NSInteger) {
        guard let datasource = self.datasource else {
            return
        }
        let rowNumber = datasource.numberOfRowWithSection(self, section: section)
        
        for row in 0..<rowNumber {
            let rowViewData = datasource.viewOfIndexpath(self, indexpath: NSIndexPath(row: row, section: section))
            let sectionView = stackViews[section]
            sectionView.contentView?.addArrangedSubview(rowViewData.view)
            if row == rowNumber - 1 {
                sectionView.updateHeight()
            }
        }
    }
    
    fileprivate func setSectionHeight(_ height : CGFloat ,section : NSInteger) {
        if height > 0 {
            guard let contentView = contentView else {
                return
            }
            let gapView = UIView()
            gapView.height(height)
            contentView.addArrangedSubview(gapView)
        }
    }
    
    fileprivate func addRowView(_ section: NSInteger,_ row: NSInteger,rowView: UIView) {
        let sectionView = stackViews[section]
        sectionView.contentView?.addArrangedSubview(rowView)
    }
    
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
        
        contentView?.left(to: self, offset:0)
        contentView?.right(to: self, offset:0)
        contentView?.top(to: self, offset:0)
        
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
