//
//  CBMACDModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct CBMACDModel {
  
  let klineModels: [CBKLineModel]
  
  init(klineModels: [CBKLineModel]) {
    self.klineModels = klineModels
  }
  
  public func fetchDrawMACDData(drawRange: NSRange? = nil) -> [CBKLineModel] {
    
    var datas = [CBKLineModel]()
    guard klineModels.count > 0 else {
      return datas
    }
    var lastEMA12: Double?
    var lastEMA26: Double?
    
    for (index, model) in klineModels.enumerated() {
      let previousModel: CBKLineModel? = index > 0 ? klineModels[index - 1] : nil
      
      let ema12 = handleEMA(day: 12, model: model, index: index, previousEMA: lastEMA12)
      let ema26 = handleEMA(day: 26, model: model, index: index, previousEMA: lastEMA26)
      lastEMA12 = ema12
      lastEMA26 = ema26
      model.DIF = handleDIF(EMA12: ema12, EMA26: ema26)
      model.DEA = handleDEA(model: model, previousModel: previousModel)
      model.MACD = handleMACD(model: model)
      
      datas.append(model)
    }
    
    if let range = drawRange {
      return Array(datas[range.location..<range.location+range.length])
    } else {
      return datas
    }
  }
  
  private func handleEMA(day: Int, model: CBKLineModel, index: Int, previousEMA: Double?) -> Double? {
    if day <= 0 || index < (day - 1) {
      return nil
    } else {
      if previousEMA != nil {
        return Double(day - 1) / Double(day + 1) * previousEMA! + 2 / Double(day + 1) * model.close
      } else {
        return 2 / Double(day + 1) * model.close
      }
    }
  }
  
  private func handleDIF(EMA12: Double?, EMA26: Double?) -> Double? {
    guard let ema12 = EMA12,
      let ema26 = EMA26 else {
        return nil
    }
    return ema12 - ema26
  }
  
  private func handleDEA(model: CBKLineModel, previousModel: CBKLineModel?) -> Double? {
    
    guard let dif = model.DIF else {
      return nil
    }
    
    if let previousDEA = previousModel?.DEA {
      return dif * 0.2 + previousDEA * 0.8
    } else {
      return dif * 0.2
    }
  }
  
  private func handleMACD(model: CBKLineModel) -> Double? {
    guard let dif = model.DIF,
      let dea = model.DEA else {
        return nil
    }
    return (dif - dea) * 2
  }
}
