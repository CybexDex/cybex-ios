//
//  CBKLineVolumeView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class CBKLineVolumeView: UIView {

  // MARK: - Property
  public var limitValueChanged: ((_ limitValue: (minValue: Double, maxValue: Double)?) -> Void)?

  fileprivate let configuration = CBConfiguration.sharedConfiguration
  fileprivate var volumeDrawKLineModels: [CBKLineModel]?

  fileprivate var drawAssistString: NSAttributedString?

  fileprivate var drawMaxY: CGFloat {
    get {
      return bounds.height
    }
  }
  fileprivate var drawHeight: CGFloat {
    get {
      return bounds.height
    }
  }

  // MARK: - LifeCycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public

  public func drawVolumeView() {
    fetchVolumeDrawKLineModels()
    setNeedsDisplay()
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    // 背景色
    context.clear(rect)
    context.setFillColor(configuration.volume.backgroundColor.cgColor)
    context.fill(rect)

    // 没有数据 不绘制
    guard let volumeDrawKLineModels = volumeDrawKLineModels,
      let limitValue = fetchLimitValue() else {
        return
    }

//    guard CGRect.isSame(rect, bounds)
//      else {
//
//        drawAssistString?.draw(in: rect)
//        return
//    }

    // 绘制指标数据
//    fetchAssistString(model: volumeDrawKLineModels.last!)
//    drawAssistString?.draw(in: rect)

    context.saveGState()

    context.move(to: CGPoint(x: 15, y: 0))
    context.addLine(to: CGPoint(x: width - 15, y: 0))
    context.setStrokeColor(configuration.theme.dashColor.cgColor)
    context.setLineWidth(configuration.theme.dashWidth)
    context.setLineDash(phase: 0, lengths: [1, 5])
    context.strokePath()

    context.restoreGState()

    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)

    var strokeColors: [UIColor] = []

    for (index, klineModel) in volumeDrawKLineModels.enumerated() {
      let xPosition = CGFloat(index) * (configuration.theme.klineWidth + configuration.theme.klineSpace)

      let yPosition = abs(drawMaxY - CGFloat((klineModel.volume - limitValue.minValue) / unitValue))
      let startPoint = CGPoint(x: xPosition, y: yPosition)
      let endPoint = CGPoint(x: xPosition, y: bounds.height)

      var strokeColor: UIColor = configuration.theme.increaseColor
      let last_model: CBKLineModel? = index >= 1 ? volumeDrawKLineModels[index - 1] : nil

      if klineModel.volume == 0, let _ = last_model {
        strokeColor = strokeColors[index - 1]
      }

      if klineModel.open == klineModel.close, let lastmodel = last_model {
        strokeColor = klineModel.close < lastmodel.close ? configuration.theme.decreaseColor : configuration.theme.increaseColor
      }

      if klineModel.open > klineModel.close {
        strokeColor = configuration.theme.decreaseColor
      }

      strokeColors.append(strokeColor)

      let path = UIBezierPath(roundedRect: CGRect(x: xPosition, y: startPoint.y, width: configuration.theme.klineWidth, height: abs(endPoint.y - startPoint.y)), cornerRadius: configuration.theme.klineRadius).cgPath
      context.addPath(path)
      context.setFillColor(strokeColor.withAlphaComponent(0.2).cgColor)
      context.fillPath()

    }
    context.strokePath()

    // 画指标线
    switch configuration.volume.indicatorType {
    case .MA_VOLUME:
      drawMA_VOLUME(context: context, limitValue: limitValue, drawModels: volumeDrawKLineModels)
    case .EMA_VOLUME:
      drawEMA_VOLUME(context: context, limitValue: limitValue, drawModels: volumeDrawKLineModels)
    default:
      break
    }
  }
}

// MARK: - 辅助视图相关
extension CBKLineVolumeView {

  fileprivate func fetchAssistString(model: CBKLineModel?) {

    guard let volumeDrawKLineModels = volumeDrawKLineModels else { return }

    var drawModel = volumeDrawKLineModels.last!

    if let model = model {
      for volumeModel in volumeDrawKLineModels {
        if model.date == volumeModel.date {
          drawModel = volumeModel
          break
        }
      }
    }
    let drawAttrsString = NSMutableAttributedString()
    let volumeStr = String(format: "VOLUME %.2f  ", drawModel.volume)

    let volumeAttrs: [NSAttributedString.Key: Any]? = [
      NSAttributedString.Key.foregroundColor: configuration.main.dateAssistTextColor,
      NSAttributedString.Key.font: configuration.main.dateAssistTextFont
    ]
    drawAttrsString.append(NSAttributedString(string: volumeStr, attributes: volumeAttrs))

    switch configuration.volume.indicatorType {
    case .MA_VOLUME(let days):

      for (idx, color) in [configuration.theme.MA1, configuration.theme.MA2, configuration.theme.MA3].enumerated() {

        let attrs: [NSAttributedString.Key: Any]? = [
          NSAttributedString.Key.foregroundColor: color,
          NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        if let value = drawModel.MA_VOLUMEs![idx] {
          let maStr = String(format: "MAVOL\(days[idx]): %.2f ", value)
          drawAttrsString.append(NSAttributedString(string: maStr, attributes: attrs))
        }
      }

    case .EMA_VOLUME(let days):
      for (idx, color) in [configuration.theme.EMA1, configuration.theme.EMA2].enumerated() {

        let attrs: [NSAttributedString.Key: Any]? = [
          NSAttributedString.Key.foregroundColor: color,
          NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        if let value = drawModel.EMA_VOLUMEs![idx] {
          let maStr = String(format: "EMAVOL\(days[idx]): %.2f ", value)
          drawAttrsString.append(NSAttributedString(string: maStr, attributes: attrs))
        }
      }

    default:
      break
    }

    drawAssistString = drawAttrsString
  }
}

// MARK: - 绘制指标
extension CBKLineVolumeView {

  fileprivate func drawMA_VOLUME(context: CGContext,
                                 limitValue: (minValue: Double, maxValue: Double),
                                 drawModels: [CBKLineModel]) {
//    _ = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)

//    switch configuration.volume.indicatorType {
//    case .MA_VOLUME( _):

//      for (idx, day) in days.enumerated() {
//
//        let maLineBrush = CBMALineBrush(brushType: .MA_VOLUME(day),
//                                        context: context)
//
//        maLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
//
//          if let value = model.MA_VOLUMEs?[idx] {
//
//            let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
//              self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
//
//            let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
//
//            return CGPoint(x: xPosition, y: yPosition)
//          }
//          return nil
//        }
//        maLineBrush.draw(drawModels: drawModels)
//      }
//      break
//    default:
//      break
//    }
  }

  fileprivate func drawEMA_VOLUME(context: CGContext,
                                  limitValue: (minValue: Double, maxValue: Double),
                                  drawModels: [CBKLineModel]) {
//    _ = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
//
//    switch configuration.volume.indicatorType {
//    case .EMA_VOLUME(let _):

//      for (idx, day) in days.enumerated() {
//
//        let emaLineBrush = CBMALineBrush(brushType: .EMA_VOLUME(day),
//                                         context: context)
//
//        emaLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
//
//          if let value = model.EMA_VOLUMEs?[idx] {
//
//            let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
//              self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
//
//            let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
//
//            return CGPoint(x: xPosition, y: yPosition)
//          }
//          return nil
//        }
//        emaLineBrush.draw(drawModels: drawModels)
//      }
//      break
//    default:
//      break
//    }
  }
}

// MARK: - 获取相关数据
extension CBKLineVolumeView {

  /// 获取视图绘制模型数据
  fileprivate func fetchVolumeDrawKLineModels() {

    guard configuration.dataSource.klineModels.count > 0 else {
      volumeDrawKLineModels = nil
      return
    }

    switch configuration.volume.indicatorType {
    case .MA_VOLUME:

      let maModel = CBMAVOLUMEModel(indicatorType: configuration.volume.indicatorType,
                                    klineModels: configuration.dataSource.klineModels)
      volumeDrawKLineModels = maModel.fetchDrawMAVOLUMEData(drawRange: configuration.dataSource.drawRange)

    case .EMA_VOLUME:

      let emaModel = CBEMAVOLUMEModel(indicatorType: configuration.volume.indicatorType,
                                      klineModels: configuration.dataSource.klineModels)
      volumeDrawKLineModels = emaModel.fetchDrawEMAVOLUMEData(drawRange: configuration.dataSource.drawRange)

    default:
      volumeDrawKLineModels = configuration.dataSource.drawKLineModels
    }
  }

  /// 获取极限值
  fileprivate func fetchLimitValue() -> (minValue: Double, maxValue: Double)? {

    guard let volumeDrawKLineModels = volumeDrawKLineModels else {
      return nil
    }

    var minValue = 0.0//volumeDrawKLineModels[0].volume
    var maxValue = volumeDrawKLineModels[0].volume

    // 先求K线数据的最大最小
    for model in volumeDrawKLineModels {
      if model.volume < minValue {
        minValue = model.volume
      }
      if model.volume > maxValue {
        maxValue = model.volume
      }

      // 求指标数据的最大最小
      switch configuration.volume.indicatorType {
      case .MA_VOLUME:
        if let MAs = model.MA_VOLUMEs {
          for value in MAs {
            if let value = value {
              minValue = value < minValue ? value : minValue
              maxValue = value > maxValue ? value : maxValue
            }
          }
        }
      case .EMA_VOLUME:
        if let EMAs = model.EMA_VOLUMEs {
          for value in EMAs {
            if let value = value {
              minValue = value < minValue ? value : minValue
              maxValue = value > maxValue ? value : maxValue
            }
          }
        }
      default:
        break
      }
    }
    limitValueChanged?((minValue, maxValue))
    return (minValue, maxValue)
  }
}
