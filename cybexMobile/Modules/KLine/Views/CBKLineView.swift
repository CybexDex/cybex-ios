//
//  CBKLineView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints

class CBKLineView: UIView {
    
    private var klineDrawView: CBKLineDrawView!
    private var accessHorizentalView: AccessoryHorizentalView!
    private var timeGapView: TimeGapView!
    
    private let configuration = CBConfiguration.sharedConfiguration
    var indicator:indicator = .ma {
        didSet {
            refreshAccessoryHorizentalView(indicator)
            klineDrawView.switchToAccessory(indicator == .macd)
            klineDrawView.removeIndicatorLine()
        }
    }
    
    var timeGap:candlesticks = .one_day {
        didSet {
            timeGapView.switchButton(candlesticks.all.index(of: timeGap)!)
            klineDrawView.removeIndicatorLine()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        loadSubView()
    }
    
    public func drawKLineView(klineModels: [CBKLineModel], initialize: Bool = true) {
        configuration.dataSource.klineModels = klineModels
        klineDrawView.drawKLineView(initialize)
    }
    
    func loadSubView() {
        loadAccessoryCollectionView()
        loadTimeGapView()
        loadingDrawView()
    }
    
    func loadAccessoryCollectionView() {
        accessHorizentalView = AccessoryHorizentalView()
        refreshAccessoryHorizentalView(self.indicator)
        addSubview(accessHorizentalView)
        
        accessHorizentalView.left(to: self)
        accessHorizentalView.top(to: self)
        accessHorizentalView.right(to: self)
        accessHorizentalView.height(56)
    }
    
    func refreshAccessoryHorizentalView(_ indicator:indicator) {
        accessHorizentalView.data = indicator
    }
    
    
    func loadTimeGapView() {
        timeGapView = TimeGapView()
        addSubview(timeGapView)
        
        timeGapView.left(to: self, offset:15)
        timeGapView.bottom(to: self)
        timeGapView.right(to: self, offset:-15)
        timeGapView.height(60)
    }
    
    private func loadingDrawView() {
        klineDrawView = CBKLineDrawView()
        addSubview(klineDrawView)
        
        klineDrawView.topToBottom(of: accessHorizentalView)
        klineDrawView.left(to: self)
        klineDrawView.right(to: self)
        klineDrawView.bottomToTop(of: timeGapView)
    }
}
