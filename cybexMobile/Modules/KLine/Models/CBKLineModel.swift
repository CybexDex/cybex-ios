//
//  CBKLineModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
/// k线类型
enum CBKLineDataType: Int {
    case BTC
    case ETH
    case CYB
    case other
}



class CBKLineModel: ObjectDescriptable {
    
    var klineDataType: CBKLineDataType
    // 日期
    var date: Double
    // 开盘价
    var open: Double
    // 收盘价
    var close: Double
    // 最高价
    var high: Double
    // 最低价
    var low: Double
    // 成交量
    var volume: Double
    // 成交量
    var towardsVolume: Double
    
    // MARK: 指标
    // 该model以及之前所有开盘价之和
    var sumOpen: Double?
    
    // 该model以及之前所有收盘价之和
    var sumClose: Double?
    
    // 该model以及之前所有最高价之和
    var sumHigh: Double?
    
    // 该model以及之前所有最低价之和
    var sumLow: Double?
    
    // 该model以及之前所有成交量之和
    var sumVolume: Double?
    
    var precision:Int
    
    // MARK: MA - MA(N) = (C1+C2+……CN) / N, C:收盘价
    var MAs: [Double?]?
    var MA_VOLUMEs: [Double?]?
    
    // MARK: EMA - EMA(N) = 2 / (N+1) * (C-昨日EMA) + 昨日EMA, C:收盘价
    var EMAs: [Double?]?
    var EMA_VOLUMEs: [Double?]?
    
    // MARK: MACD
    
    // DIF = EMA(12) - EMA(26)
    var DIF: Double?
    // DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
    var DEA: Double?
    // MACD(12,26,9) = (DIF - DEA) * 2
    var MACD: Double?
    
    // MARK: KDJ(9,3,3) 代表指标分析周期为9天，K值D值为3天
    // 九个交易日内最低价
    var minPriceOfNineClock: Double?
    // 九个交易日最高价
    var maxPriceOfNineClock: Double?
    // RSV(9) =（今日收盘价－9日内最低价）/（9日内最高价－9日内最低价）* 100
    var RSV9: Double?
    // K(3) =（当日RSV值+2*前一日K值）/ 3
    var KDJ_K: Double?
    // D(3) =（当日K值 + 2*前一日D值）/ 3
    var KDJ_D: Double?
    // J = 3K － 2D
    var KDJ_J: Double?
    
    // MARK: BOLL
    // 中轨线
    var BOLL_MB: Double?
    // 上轨线
    var BOLL_UP: Double?
    // 下轨线
    var BOLL_DN: Double?
    
    var change: String = "-"
    
    var changeAmount: String = "-"
    
    var incre:changeScope = .equal
    
    init(klineDataType: CBKLineDataType = .CYB,
         date: Double,
         open: Double,
         close: Double,
         high: Double,
         low: Double,
         towardsVolume:Double,
         volume: Double,
         precision: Int) {
        self.klineDataType = klineDataType
        self.date = date
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.volume = volume
        self.towardsVolume = towardsVolume
        self.precision = precision
        
        
    }
}

extension CBKLineModel: Hashable {
    public var hashValue: Int {
        return Int(self.date + self.open + self.close + self.high + self.low +  self.volume + self.towardsVolume) + self.precision
    }
    
    static func == (lhs: CBKLineModel, rhs: CBKLineModel) -> Bool {
        return lhs.date == rhs.date &&
            lhs.open == rhs.open &&
            lhs.close == rhs.close &&
            lhs.high == rhs.high &&
            lhs.low == rhs.low &&
            lhs.volume == rhs.volume &&
            lhs.high == rhs.high &&
            lhs.towardsVolume == rhs.towardsVolume &&
            lhs.precision == rhs.precision &&
            lhs.sumOpen == rhs.sumOpen &&
            lhs.BOLL_DN == rhs.BOLL_DN &&
            lhs.BOLL_MB == rhs.BOLL_MB &&
            lhs.BOLL_UP == rhs.BOLL_UP &&
            lhs.DEA == rhs.DEA &&
            lhs.DIF == rhs.DIF &&
            lhs.EMA_VOLUMEs == rhs.EMA_VOLUMEs &&
            lhs.EMAs == rhs.EMAs &&
            lhs.KDJ_D == rhs.KDJ_D &&
            lhs.KDJ_J == rhs.KDJ_J &&
            lhs.KDJ_K == rhs.KDJ_K &&
            lhs.MACD == rhs.MACD
    }
}
