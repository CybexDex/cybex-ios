//
//  CBMAVOLUMEModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct CBMAVOLUMEModel {

  let indicatorType: CBIndicatorType
  let klineModels: [CBKLineModel]

  init(indicatorType: CBIndicatorType, klineModels: [CBKLineModel]) {
    self.indicatorType = indicatorType
    self.klineModels = klineModels
  }

  public func fetchDrawMAVOLUMEData(drawRange: NSRange?) -> [CBKLineModel] {

    var datas = [CBKLineModel]()

    guard klineModels.count > 0 else {
      return datas
    }

    for (index, model) in klineModels.enumerated() {

      model.sumVolume = model.volume + (index > 0 ? klineModels[index - 1].sumVolume! : 0)

      switch indicatorType {
      case .MAVolume(let days):
        var values = [Double?]()
        for day in days {

          values.append(handleMA_VOLUME(day: day, model: model, index: index, models: klineModels))
        }
        model.MAVolumes = values
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
  private func handleMA_VOLUME(day: Int, model: CBKLineModel, index: Int, models: [CBKLineModel]) -> Double? {
    if day <= 0 || index < (day - 1) {
      return nil
    } else if index == (day - 1) {
      return model.sumVolume! / Double(day)
    } else {
      return (model.sumVolume! - models[index - day].sumVolume!) / Double(day)
    }
  }
}
