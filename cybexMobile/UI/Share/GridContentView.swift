//
//  GridContentView.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@objc protocol GridContentViewDelegate: NSObjectProtocol {
    @objc func itemDidSelect(_  view: GridContentView, index: NSInteger)
}

@objc protocol GridContentViewDataSource: NSObjectProtocol {
    func itemsForView(_  view: GridContentView) -> [UIView]
    
    @objc optional func edgeInsetsForView(_  view: GridContentView) -> UIEdgeInsets
    
    @objc optional func lineGapForView(_ view: GridContentView) -> CGFloat
    
    @objc optional func lineMaxItemNum(_ view: GridContentView) -> Int
    
    @objc optional func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat
}

class GridContentView: UIView {
    weak var delegate: GridContentViewDelegate?
    
    weak var datasource: GridContentViewDataSource?
    
    private var edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(30, 25, 30, 25)
    
    private var lineGap: CGFloat = 25
    
    private var lineNum: Int = 4
    
    private var itemSize: CGSize = CGSize(width: 48, height: 48)
    
    private var collectionViews: [UIView] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadData()
        setupUI()
    }
    
    private func setupUI() {
        if collectionViews.count > 0 {
            let contentView = UIStackView(frame: CGRect.zero)
            contentView.axis = .vertical
            contentView.distribution = .equalSpacing
            contentView.alignment = .fill
            contentView.spacing = self.lineGap
            self.addSubview(contentView)
            contentView.left(to: self, offset:edgeInsets.left)
            contentView.right(to: self, offset:-edgeInsets.right)
            contentView.top(to: self, offset:edgeInsets.top)
            
            var rows: Int = collectionViews.count / self.lineNum
            if collectionViews.count % self.lineNum > 0 {
                rows += 1
            }
            for row in 0 ..< rows {
                let lineView = UIStackView(frame: CGRect.zero)
                lineView.axis = .horizontal
                lineView.distribution = .fillEqually
                lineView.alignment = .fill
                contentView.addArrangedSubview(lineView)
                lineView.left(to: contentView, offset:0)
                lineView.right(to: contentView, offset:0)
                updateLineHeight(lineView, lineNum: row)
                
                for rowIndex in 0 ..< self.lineNum {
                    let index = row * self.lineNum + rowIndex
                    if index < collectionViews.count {
                        lineView.addArrangedSubview(collectionViews[index])
                    } else {
                        lineView.addArrangedSubview(cleanView())
                    }
                }
            }
            updateHeight()
        }
    }
    
    fileprivate func updateLineHeight(_ lineView: UIStackView, lineNum: Int) {
        if let dataSource = self.datasource {
            if dataSource.responds(to: #selector(GridContentViewDataSource.lineHeightForView(_:lineNum:))) {
                let height = dataSource.lineHeightForView!(self, lineNum: lineNum)
                if height > 0 {
                    lineView.height(height)
                }
            }
        }
    }
    
    func cleanView() -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.size = itemSize
        view.backgroundColor = UIColor.clear
        return view
    }
    
    private func loadData() {
        if let dataSource = self.datasource {
            if dataSource.responds(to: #selector(GridContentViewDataSource.edgeInsetsForView(_:))) {
                self.edgeInsets = dataSource.edgeInsetsForView!(self)
            }
            
            if dataSource.responds(to: #selector(GridContentViewDataSource.lineGapForView(_:))) {
                self.lineGap = dataSource.lineGapForView!(self)
            }
            
            if dataSource.responds(to: #selector(GridContentViewDataSource.lineMaxItemNum(_:))) {
                self.lineNum = dataSource.lineMaxItemNum!(self)
            }
            
            
            self.collectionViews = dataSource.itemsForView(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        loadData()
        removeAllSubViews()
        setupUI()
    }
    
    func removeAllSubViews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
    }
    
    @objc func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom + edgeInsets.bottom + edgeInsets.top
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
}
