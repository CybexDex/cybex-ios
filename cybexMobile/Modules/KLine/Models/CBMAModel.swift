//
//  CBMAModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct CBMAModel {

  let indicatorType: CBIndicatorType
  let klineModels: [CBKLineModel]

  init(indicatorType: CBIndicatorType, klineModels: [CBKLineModel]) {
    self.indicatorType = indicatorType
    self.klineModels = klineModels
  }

  public func fetchDrawMAData(drawRange: NSRange?) -> [CBKLineModel] {

    var datas = [CBKLineModel]()

    guard klineModels.count > 0 else {
      return datas
    }

    for (index, model) in klineModels.enumerated() {

      model.sumClose = model.close + (index > 0 ? klineModels[index - 1].sumClose! : 0)

      switch indicatorType {
      case .MA(let days):
        var values = [Double?]()
        for day in days {

          values.append(handleMA(day: day, model: model, index: index, models: klineModels))
        }
        model.MAs = values
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

  private func handleMA(day: Int, model: CBKLineModel, index: Int, models: [CBKLineModel]) -> Double? {
    if day <= 0 || index < (day - 1) {
      return nil
    } else if index == (day - 1) {
      return model.sumClose! / Double(day)
    } else {
      return (model.sumClose! - models[index - day].sumClose!) / Double(day)
    }
  }
}
