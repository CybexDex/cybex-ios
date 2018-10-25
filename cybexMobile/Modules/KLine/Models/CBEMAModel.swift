//
//  CBEMAModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct CBEMAModel {

  let indicatorType: CBIndicatorType
  let klineModels: [CBKLineModel]

  init(indicatorType: CBIndicatorType, klineModels: [CBKLineModel]) {
    self.indicatorType = indicatorType
    self.klineModels = klineModels
  }

  public func fetchDrawEMAData(drawRange: NSRange? = nil) -> [CBKLineModel] {

    var datas = [CBKLineModel]()

    guard klineModels.count > 0 else {
      return datas
    }

    for (index, model) in klineModels.enumerated() {

      switch indicatorType {
      case .EMA(let days):

        var values = [Double?]()

        for (idx, day) in days.enumerated() {

          let previousEMA: Double? = index > 0 ? datas[index - 1].EMAs?[idx] : nil
          values.append(handleEMA(day: day, model: model, index: index, previousEMA: previousEMA))
        }
        model.EMAs = values
      default:
        break
      }
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
}
