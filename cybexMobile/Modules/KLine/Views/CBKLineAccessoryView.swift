//
//  CBKLineAccessoryView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme
class CBKLineAccessoryView: UIView {

  // MARK: - Property
  public var limitValueChanged: ((_ limitValue: (minValue: Double, maxValue: Double)?) -> Void)?

  fileprivate let configuration = CBConfiguration.sharedConfiguration
  fileprivate var accessoryDrawKLineModels: [CBKLineModel]?
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

//  fileprivate var drawIndicationModels: [CBKLineModel] {
//    get {
//      let kdjModel = OKKDJModel(klineModels: configuration.dataSource.klineModels)
//      return kdjModel.fetchDrawKDJData(drawRange: configuration.dataSource.drawRange)
//    }
//  }

  //    convenience init(configuration: OKConfiguration) {
  //        self.init()
  //        self.configuration = configuration
  //    }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public

  public func drawAccessoryView() {

    fetchAccessoryDrawKLineModels()
    setNeedsDisplay()
  }

  public func drawAssistView(model: CBKLineModel?) {

    fetchAssistString(model: model)
    let displayRect = CGRect(x: 0,
                             y: 0,
                             width: bounds.width,
                             height: configuration.accessory.topViewHeight)

    setNeedsDisplay(displayRect)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    // 背景色
    context.clear(rect)
//    context.setFillColor(configuration.accessory.backgroundColor[configuration.themeIndex].cgColor)
//    context.fill(rect)

    // 没有数据 不绘制
    guard let accessoryDrawKLineModels = accessoryDrawKLineModels else {
      return
    }

//    guard CGRect.isSame(rect, bounds)
//      else {
//
//        drawAssistString?.draw(in: rect)
//        return
//    }
//
    context.saveGState()
    let strokeColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.white
    context.move(to: CGPoint(x: 15, y: 0))
    context.addLine(to: CGPoint(x: width - 15, y: 0))
    context.setStrokeColor(strokeColor.cgColor)
    context.setLineWidth(configuration.theme.dashWidth)
    context.setLineDash(phase: 0, lengths: [1, 5])
    context.strokePath()

    context.restoreGState()

//    fetchAssistString(model: accessoryDrawKLineModels.last!)
//    drawAssistString?.draw(in: rect)

    switch configuration.accessory.indicatorType {
    case .MACD:
      drawMACD(context: context, drawModels: accessoryDrawKLineModels)

    case .KDJ:
      drawKDJ(context: context, drawModels: accessoryDrawKLineModels)

    default:
      break
    }
  }
}

// MARK: - 辅助视图相关
extension CBKLineAccessoryView {

  fileprivate func fetchAssistString(model: CBKLineModel?) {

    guard let accessoryDrawKLineModels = accessoryDrawKLineModels else { return }

    var drawModel = accessoryDrawKLineModels.last!

    if let model = model {
      for accessoryModel in accessoryDrawKLineModels {
        if model.date == accessoryModel.date {
          drawModel = accessoryModel
          break
        }
      }
    }

    let drawAttrsString = NSMutableAttributedString()
    switch configuration.accessory.indicatorType {
    case .MACD:
        let attrs: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.main.dateAssistTextColor,
            NSAttributedString.Key.font: configuration.main.dateAssistTextFont
      ]
      drawAttrsString.append(NSAttributedString(string: "MACD(12,26,9) ", attributes: attrs))

      if let dif = drawModel.DIF {
        let difAttrs: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.theme.DIFColor,
            NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        let difAttrsStr = NSAttributedString(string: String(format: "DIF: %.2f ", dif), attributes: difAttrs)
        drawAttrsString.append(difAttrsStr)
      }
      if let dea = drawModel.DEA {
        let deaAttrs: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.theme.DEAColor,
            NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        let deaAttrsStr = NSAttributedString(string: String(format: "DEA: %.2f ", dea), attributes: deaAttrs)
        drawAttrsString.append(deaAttrsStr)
      }
      if let macd = drawModel.MACD {

        let macdAttrs: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.theme.MACDColor,
            NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        let macdAttrsStr = NSAttributedString(string: String(format: "MACD: %.2f ", macd), attributes: macdAttrs)
        drawAttrsString.append(macdAttrsStr)
      }

    case .KDJ:
      break
//      let attrs: [NSAttributedStringKey : Any]? = [
//        NSAttributedStringKey.foregroundColor : configuration.main.assistTextColor,
//        NSAttributedStringKey.font : configuration.main.assistTextFont
//      ]
//      drawAttrsString.append(NSAttributedString(string: "KDJ(9,3,3) ", attributes: attrs))
//
//      if let value = drawModel.KDJ_K {
//        let kAttrs: [NSAttributedStringKey : Any]? = [
//          NSAttributedStringKey.foregroundColor : configuration.theme.KDJ_KColor,
//          NSAttributedStringKey.font : configuration.main.assistTextFont
//        ]
//        let kAttrsStr = NSAttributedString(string: String(format: "K: %.2f ", value), attributes: kAttrs)
//        drawAttrsString.append(kAttrsStr)
//      }
//      if let value = drawModel.KDJ_D {
//        let dAttrs: [NSAttributedStringKey : Any]? = [
//          NSAttributedStringKey.foregroundColor : configuration.theme.KDJ_DColor,
//          NSAttributedStringKey.font : configuration.main.assistTextFont
//        ]
//        let dAttrsStr = NSAttributedString(string: String(format: "D: %.2f ", value), attributes: dAttrs)
//        drawAttrsString.append(dAttrsStr)
//      }
//      if let value = drawModel.KDJ_J {
//        let jAttrs: [NSAttributedStringKey : Any]? = [
//          NSAttributedStringKey.foregroundColor : configuration.theme.KDJ_JColor,
//          NSAttributedStringKey.font : configuration.main.assistTextFont
//        ]
//        let jAttrsStr = NSAttributedString(string: String(format: "J: %.2f ", value), attributes: jAttrs)
//        drawAttrsString.append(jAttrsStr)
//      }

    default:
      break
    }
    drawAssistString = drawAttrsString
  }
}

// MARK: - 绘制指标
extension CBKLineAccessoryView {

  // MARK: 绘制MACD
  fileprivate func drawMACD(context: CGContext, drawModels: [CBKLineModel]) {

    guard let limitValue = fetchLimitValue() else {
      return
    }

    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
    let middleY = unitValue != 0 ? drawMaxY - CGFloat(abs(limitValue.minValue) / unitValue) : drawMaxY

    // 画柱状图
    for (index, model) in drawModels.enumerated() {

      let xPosition = CGFloat(index) * (configuration.theme.klineWidth + configuration.theme.klineSpace)

      var startPoint = CGPoint(x: xPosition, y: middleY)
      var endPoint = CGPoint(x: xPosition, y: middleY)
      if let macd = model.MACD {

        let offsetValue = CGFloat(abs(macd) / unitValue)

        startPoint.y = macd > 0 ? middleY - offsetValue : middleY
        endPoint.y = macd > 0 ? middleY : middleY + offsetValue

        let strokeColor = macd > 0 ?
          configuration.theme.increaseColor : configuration.theme.decreaseColor

        let path = UIBezierPath(roundedRect: CGRect(x: xPosition,
                                                    y: startPoint.y,
                                                    width: configuration.theme.klineWidth,
                                                    height: abs(endPoint.y - startPoint.y)),
                                cornerRadius: configuration.theme.klineRadius).cgPath
        context.addPath(path)
        context.setFillColor(strokeColor.withAlphaComponent(0.2).cgColor)
        context.fillPath()
      }
    }
    context.strokePath()

    // 画DIF线
    let difLineBrush = CBLineBrush(indicatorType: .DIF,
                                   context: context)
    difLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)

      if let value = model.DIF {
        let yPosition = CGFloat(-(value) / unitValue) + middleY
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    difLineBrush.draw(drawModels: drawModels)

    // 画DEA线
    let deaLineBrush = CBLineBrush(indicatorType: .DEA,
                                   context: context)
    deaLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.DEA {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
        let yPosition = CGFloat(-(value) / unitValue) + middleY
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    deaLineBrush.draw(drawModels: drawModels)
  }

  // MARK: 绘制KDJ
  fileprivate func drawKDJ(context: CGContext, drawModels: [CBKLineModel]) {

    guard let limitValue = fetchLimitValue() else { return }

    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)

    let KDJKLineBrush = CBLineBrush(indicatorType: .kdjK, context: context)
    KDJKLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.KDJk {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
        let yPosition: CGFloat = unitValue != 0 ? abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue)) : self.drawMaxY
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    KDJKLineBrush.draw(drawModels: drawModels)

    let KDJDLineBrush = CBLineBrush(indicatorType: .kdjD, context: context)
    KDJDLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.KDJd {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
        let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    KDJDLineBrush.draw(drawModels: drawModels)

    let KDJJLineBrush = CBLineBrush(indicatorType: .kdjJ, context: context)
    KDJJLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.KDJj {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
        let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    KDJJLineBrush.draw(drawModels: drawModels)
  }
}

// MARK: - 获取相关数据
extension CBKLineAccessoryView {

  fileprivate func fetchAccessoryDrawKLineModels() {

    guard configuration.dataSource.klineModels.count > 0 else {
      accessoryDrawKLineModels = nil
      return
    }

    switch configuration.accessory.indicatorType {
    case .MACD:
      let macdModel = CBMACDModel(klineModels: configuration.dataSource.klineModels)
      accessoryDrawKLineModels = macdModel.fetchDrawMACDData(drawRange: configuration.dataSource.drawRange)

    case .KDJ:
//      let kdjModel = OKKDJModel(klineModels: configuration.dataSource.klineModels)
//      accessoryDrawKLineModels = kdjModel.fetchDrawKDJData(drawRange: configuration.dataSource.drawRange)
      break
    default:
      break
    }
  }

  // MARK: - 获取指标数据最大最小值
  fileprivate func fetchLimitValue() -> (minValue: Double, maxValue: Double)? {

    guard let accessoryDrawKLineModels = accessoryDrawKLineModels else {
      return nil
    }

    var minValue = 0.0
    var maxValue = 0.0

    switch configuration.accessory.indicatorType {
    case .MACD:
      for model in accessoryDrawKLineModels {
        if let value = model.DIF {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        if let value = model.DEA {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        if let value = model.MACD {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
      }

    case .KDJ:

      for model in accessoryDrawKLineModels {

        if let value = model.KDJk {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }

        if let value = model.KDJd {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        if let value = model.KDJj {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
      }

    default:
      break
    }
    limitValueChanged?((minValue, maxValue))
    return (minValue, maxValue)
  }
}
