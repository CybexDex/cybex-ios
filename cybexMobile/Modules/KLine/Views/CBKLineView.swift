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
    
    enum Event: String {
        case openMessageVC
    }
    
    private var klineDrawView: CBKLineDrawView!
    private var accessHorizentalView: AccessoryHorizentalView!
    private var timeGapView: TimeGapView!
    
    private var boxView: CBKKindView!
//    private var messageView: CBKMessageView!
    
    private let configuration = CBConfiguration.sharedConfiguration
    var indicator: Indicator = .ma {
        didSet {
            //            refreshAccessoryHorizentalView(indicator)
            klineDrawView.switchToAccessory(indicator == .macd)
            klineDrawView.removeIndicatorLine()
        }
    }
    
    var timeGap: Candlesticks = .oneDay {
        didSet {
            //            timeGapView.switchButton(Candlesticks.all.index(of: timeGap)!)
            klineDrawView.removeIndicatorLine()
        }
    }
    
//    var messageCount: Int = 0 {
//        didSet {
//            messageView.messageNumberLabel.text = "\(messageCount)"
//        }
//    }
    
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
        //        loadAccessoryCollectionView()
        loadKineView()
        //        loadTimeGapView()
//        loadMessageView()
        
        loadingDrawView()
    }
    
//    func loadMessageView() {
//        messageView = CBKMessageView()
//        addSubview(messageView)
//
//        messageView.left(to: self, offset: 0)
//        messageView.bottom(to: self)
//        messageView.right(to: self, offset: 0)
//        messageView.height(48)
//    }
    
    func loadKineView() {
        boxView = CBKKindView()
        addSubview(boxView)
        boxView.left(to: self)
        boxView.top(to: self)
        boxView.right(to: self)
        boxView.height(44)
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
    
    func refreshAccessoryHorizentalView(_ indicator: Indicator) {
        accessHorizentalView.data = indicator
    }
    
    func loadTimeGapView() {
        timeGapView = TimeGapView()
        addSubview(timeGapView)
        
        timeGapView.left(to: self, offset: 15)
        timeGapView.bottom(to: self)
        timeGapView.right(to: self, offset: -15)
        timeGapView.height(60)
    }
    
    private func loadingDrawView() {
        klineDrawView = CBKLineDrawView()
        addSubview(klineDrawView)
        
        klineDrawView.topToBottom(of: boxView)
        klineDrawView.left(to: self)
        klineDrawView.right(to: self)
        klineDrawView.bottom(to: self)
//        klineDrawView.bottomToTop(of: messageView)
    }
}

extension CBKLineView {
//    @objc func cBKMessageViewDidClicked(_ data: [String: Any]) {
//        self.next?.sendEventWith(Event.openMessageVC.rawValue, userinfo: data)
//    }
}
