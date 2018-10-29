//
//  CBEMAVOLUMEModel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct CBEMAVOLUMEModel {

  let indicatorType: CBIndicatorType
  let klineModels: [CBKLineModel]

  init(indicatorType: CBIndicatorType, klineModels: [CBKLineModel]) {
    self.indicatorType = indicatorType
    self.klineModels = klineModels
  }

  public func fetchDrawEMAVOLUMEData(drawRange: NSRange?) -> [CBKLineModel] {

    var datas = [CBKLineModel]()

    guard klineModels.count > 0 else {
      return datas
    }

    for (index, model) in klineModels.enumerated() {

      switch indicatorType {
      case .EMAVolume(let days):

        var values = [Double?]()

        for (idx, day) in days.enumerated() {

          let previousEMAVolume: Double? = index > 0 ? datas[index - 1].EMAVolumes?[idx] : nil
          values.append(handleEMA_VOLUME(day: day, model: model, index: index, previousEMA_VOLUME: previousEMAVolume))
        }
        model.EMAVolumes = values
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

  private func handleEMA_VOLUME(day: Int, model: CBKLineModel, index: Int, previousEMA_VOLUME: Double?) -> Double? {
    if day <= 0 || index < (day - 1) {
      return nil
    } else {
      if previousEMA_VOLUME != nil {
        return Double(day - 1) / Double(day + 1) * previousEMA_VOLUME! + 2 / Double(day + 1) * model.volume
      } else {
        return 2 / Double(day + 1) * model.volume
      }
    }
  }
}
