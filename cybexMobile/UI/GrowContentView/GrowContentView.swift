//
//  GrowContentView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/20.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import TinyConstraints

struct GrowContentViewShadowModel {
    var color: UIColor = .clear
    var offset: CGSize = CGSize(width: 0, height: 0)
    var radius: CGFloat = 0
    var opacity: Float = 1
}

protocol GrowContentViewDataSource {
    func numberOfSection(_ contentView: GrowContentView) -> NSInteger
    func numberOfRowWithSection(_ contentView: GrowContentView, section: NSInteger) -> NSInteger
    func marginOfContentView(_ contentView: GrowContentView) -> CGFloat
    func heightWithSectionHeader(_ contentView: GrowContentView, section: NSInteger) -> CGFloat
    func cornerRadiusOfSection(_ contentView: GrowContentView, section: NSInteger) -> CGFloat
    func shadowSettingOfSection(_ contentView: GrowContentView, section: NSInteger) -> GrowContentViewShadowModel
    func viewOfIndexpath(_ contentView: GrowContentView, indexpath: NSIndexPath) -> (view: UIView, key: String)
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
    func reloadData() {

    }

    fileprivate func updateUI() {
        guard let datasource = self.datasource else {
            return
        }
        updateContentLayout()
        let sectionNumber = datasource.numberOfSection(self)

        for section in 0..<sectionNumber {
            let sectionHeight = datasource.heightWithSectionHeader(self, section: section)
            setSectionHeight(datasource.heightWithSectionHeader(self, section: section), section: section)

            let sectionView = self.sectionView(section, headerHeight: sectionHeight)
            contentView?.addArrangedSubview(sectionView)
            sectionView.left(to: contentView!, offset: 0)
            sectionView.right(to: contentView!, offset: 0)

            stackViews.append(sectionView)
            updateSection(section)
        }
        updateHeight()
    }

    fileprivate func updateContentLayout() {
        guard let datasource = self.datasource else {
            return
        }

        let margin: CGFloat = datasource.marginOfContentView(self)
        contentView?.left(to: self, offset: margin)
        contentView?.right(to: self, offset: -margin)
        contentView?.top(to: self, offset: 0)
    }

    fileprivate func sectionView(_ section: NSInteger, headerHeight: CGFloat) -> GrowSectionView {
        let sectionView = GrowSectionView()
        if let radius = self.datasource?.cornerRadiusOfSection(self, section: section) {
            sectionView.cornerView?.cornerRadius = radius
        }

        if let shadowSetting = self.datasource?.shadowSettingOfSection(self, section: section) {
            sectionView.shadowColor = shadowSetting.color
            sectionView.shadowOffset = shadowSetting.offset
            sectionView.shadowRadius = shadowSetting.radius
            sectionView.shadowOpacity = shadowSetting.opacity
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

    fileprivate func setSectionHeight(_ height: CGFloat, section: NSInteger) {
        if height > 0 {
            guard let contentView = contentView else {
                return
            }
            let gapView = UIView()
            gapView.height(height)
            contentView.addArrangedSubview(gapView)
        }
    }

    fileprivate func addRowView(_ section: NSInteger, _ row: NSInteger, rowView: UIView) {
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
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    @objc func updateContentSize() {
        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
    }

    @objc func updateHeight() {
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
