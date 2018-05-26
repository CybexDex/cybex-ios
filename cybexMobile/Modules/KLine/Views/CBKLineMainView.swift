//
//  CBKLineMainView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class CBKLineMainView: UIView {
  
  // MARK: - Property
  public var limitValueChanged: ((_ limitValue: (minValue: Double, maxValue: Double)?) -> Void)?
  
  fileprivate let configuration = CBConfiguration.sharedConfiguration
  
  fileprivate var lastDrawDatePoint: CGPoint = CGPoint.zero
  // 辅助视图的显示内容
  fileprivate var drawAssistString: NSAttributedString?
  // 主图绘制K线模型数组
  fileprivate var mainDrawKLineModels: [CBKLineModel]?
  
  var extraAssistHeight:CGFloat = 40
  // 绘制区域的最大Y值
  fileprivate var drawMaxY: CGFloat {
    get {
      return drawHeight + configuration.main.assistViewHeight + configuration.main.dateAssistViewHeight
    }
  }
  // 绘制区域的高度
  fileprivate var drawHeight: CGFloat {
    get {
      return height - extraAssistHeight - configuration.main.assistViewHeight - configuration.main.dateAssistViewHeight - 4
    }
  }
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  //    convenience init(configuration: OKConfiguration) {
  //        self.init()
  //        self.configuration = configuration
  //    }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func drawMainView() {
    
    fetchMainDrawKLineModels()
    
    setNeedsDisplay()
  }
  
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    // 背景色
    context.clear(rect)
    context.setFillColor(configuration.main.backgroundColor.cgColor)
    context.fill(rect)
    
    // 没有数据 不绘制
    guard let mainDrawKLineModels = mainDrawKLineModels,
      let limitValue = fetchLimitValue() else {
        return
    }


    
    // 设置日期背景色

    let assistRect = CGRect(x: 0,
                            y: 0,
                            width: rect.width,
                            height: configuration.main.dateAssistViewHeight)
    context.fill(assistRect)
    
    
    lastDrawDatePoint = CGPoint.zero
    
    
    // 绘制提示数据
    fetchAssistString(model: mainDrawKLineModels.last)
    drawAssistString?.draw(in: CGRect(x: 10, y : 15, width: width - 30, height:configuration.main.assistViewHeight))
    
    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)

    var strokeColors:[UIColor] = []
    
    for (index, klineModel) in mainDrawKLineModels.enumerated() {
      let xPosition = CGFloat(index) * (configuration.theme.klineWidth + configuration.theme.klineSpace) +
        configuration.theme.klineWidth * 0.5 + configuration.theme.klineSpace + 15

      let openPoint = CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.open - limitValue.minValue) / unitValue)))
      let closePoint = CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.close - limitValue.minValue) / unitValue)))
      let highPoint = CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.high - limitValue.minValue) / unitValue)))
      let lowPoint = CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.low - limitValue.minValue) / unitValue)))

      switch configuration.main.klineType {
      case .KLine: // K线模式

        // 决定K线颜色
        var strokeColor:UIColor = configuration.theme.increaseColor
        let last_model:CBKLineModel? = index >= 1 ? mainDrawKLineModels[index - 1] : nil
        
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
        context.setStrokeColor(strokeColor.cgColor)

        // 画开盘-收盘
        if (closePoint.y == openPoint.y) {
          context.setLineWidth(configuration.theme.klineShadowLineWidth)
          context.strokeLineSegments(between: [CGPoint(x: xPosition - configuration.theme.klineWidth / 2, y: closePoint.y), CGPoint(x: xPosition + configuration.theme.klineWidth / 2, y: closePoint.y)])
        }
        else {
          let path = UIBezierPath(roundedRect: CGRect(x:xPosition - configuration.theme.klineWidth / 2, y: klineModel.open < klineModel.close ? closePoint.y : openPoint.y, width: configuration.theme.klineWidth, height:max(abs(closePoint.y - openPoint.y), configuration.theme.klineShadowLineWidth)), cornerRadius: configuration.theme.klineRadius).cgPath
          context.addPath(path)
          context.setFillColor(strokeColor.cgColor)
          context.fillPath()
        }
        
        // 画上下影线
        context.setLineWidth(configuration.theme.klineShadowLineWidth)
        context.strokeLineSegments(between: [highPoint, lowPoint])

     
      default: break
      }
      // 画日期
      drawDateLine(context: context, klineModel: mainDrawKLineModels[index],
                   positionX: xPosition)

    }
    
    context.strokePath()

    // 绘制指标
    switch configuration.main.indicatorType {
    case .MA(_):
      drawMA(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
    case .EMA(_):
      drawEMA(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
    case .BOLL(_):
      drawBOLL(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
    default:
      break
    }
    
  }
}

// MARK: - 辅助视图(时间线,顶部显示)
extension CBKLineMainView {
  
  /// 画时间线
  ///
  /// - Parameters:
  ///   - klineModel: 数据模型
  ///   - positionModel: 位置模型
  fileprivate func drawDateLine(context: CGContext, klineModel: CBKLineModel, positionX: CGFloat) {
    
    let date = Date(timeIntervalSince1970: klineModel.date)
    let dateString = configuration.dateFormatter.string(from: date)
    
    let dateAttributes: [NSAttributedStringKey : Any]? = [
      NSAttributedStringKey.foregroundColor : configuration.main.dateAssistTextColor,
      NSAttributedStringKey.font : configuration.main.dateAssistTextFont
    ]
    
    let dateAttrString = NSAttributedString(string: dateString, attributes: dateAttributes)
    
    let drawDatePoint = CGPoint(x: positionX - dateAttrString.size().width * 0.5,
                                y: 0)
    
    if drawDatePoint.x < 0 || (drawDatePoint.x + dateAttrString.size().width) > bounds.width {
      return
    }
    
    if lastDrawDatePoint.equalTo(CGPoint.zero) ||
      abs(drawDatePoint.x - lastDrawDatePoint.x) > (dateAttrString.size().width * 2) {
      
      let rect = CGRect(x: drawDatePoint.x,
                        y: drawDatePoint.y,
                        width: dateAttrString.size().width,
                        height: configuration.main.dateAssistViewHeight)
      
      dateAttrString.draw(in: rect)
      
      context.setStrokeColor(configuration.theme.tickColor.cgColor)
      context.setLineWidth(configuration.theme.tickWidth)
      context.strokeLineSegments(between: [CGPoint(x:drawDatePoint.x + dateAttrString.size().width / 2, y:14), CGPoint(x:drawDatePoint.x + dateAttrString.size().width / 2, y:height)])

      lastDrawDatePoint = drawDatePoint
    }

  }
  
  /// 获取辅助视图显示文本
  ///
  /// - Parameter model: 当前要显示的model
  fileprivate func fetchAssistString(model: CBKLineModel?) {
    
    guard let mainDrawKLineModels = mainDrawKLineModels else { return }
    
    var drawModel = mainDrawKLineModels.last!
    
    if let model = model {
      for mainModel in mainDrawKLineModels {
        if model.date == mainModel.date {
          drawModel = mainModel
          break
        }
      }
    }
    
    let drawAttrsString = NSMutableAttributedString()
    
//    let date = Date(timeIntervalSince1970: drawModel.date)
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd HH:mm"
//    let dateStr = formatter.string(from: date) + " "
//
//    let dateAttrs: [NSAttributedStringKey : Any]? = [
//      NSAttributedStringKey.foregroundColor : configuration.main.dateAssistTextColor,
//      NSAttributedStringKey.font : configuration.main.dateAssistTextFont
//    ]
//    drawAttrsString.append(NSAttributedString(string: dateStr, attributes: dateAttrs))
    
//    let openStr = String(format: "开: %.2f ", drawModel.open)
//    let highStr = String(format: "高: %.2f ", drawModel.high)
//    let lowStr = String(format: "低: %.2f ", drawModel.low)
//    let closeStr = String(format: "收: %.2f ", drawModel.close)
    
//    let string = openStr + highStr + lowStr + closeStr
//    let attrs: [NSAttributedStringKey : Any]? = [
//      NSAttributedStringKey.foregroundColor : configuration.main.dateAssistTextColor,
//      NSAttributedStringKey.font : configuration.main.dateAssistTextFont
//    ]
    
//    drawAttrsString.append(NSAttributedString(string: string, attributes: attrs))
    
    switch configuration.main.indicatorType {
    case .MA(let days):
      
      for (idx, color) in [configuration.theme.MA1, configuration.theme.MA2, configuration.theme.MA3].enumerated() {
        let maAttrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : configuration.theme.markColor,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont,
          NSAttributedStringKey.backgroundColor: configuration.theme.markbgColor
        ]
        
        let attrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : color,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        ]
        
        if let value = drawModel.MAs![idx] {
          let maStr = String(format: "MA(\(days[idx])): ")
          drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))

          let mavalueStr = String(format: "  %.2f   ", value)
          drawAttrsString.append(NSAttributedString(string: mavalueStr, attributes: attrs))
        }
      }
      
    case .EMA(let days):
      for (idx, color) in [configuration.theme.EMA1, configuration.theme.EMA2].enumerated() {
        let maAttrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : configuration.theme.markColor,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont,
          NSAttributedStringKey.backgroundColor: configuration.theme.markbgColor
        ]
        
        let attrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : color,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        ]
        
        if let value = drawModel.EMAs![idx] {
          let maStr = String(format: "EMA(\(days[idx])): ")
          drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))
          
          let emavalueStr = String(format: "  %.2f   ", value)
          drawAttrsString.append(NSAttributedString(string: emavalueStr, attributes: attrs))
        }
      }
    case .BOLL(_):
      let maAttrs: [NSAttributedStringKey : Any]? = [
        NSAttributedStringKey.foregroundColor : configuration.theme.markColor,
        NSAttributedStringKey.font : configuration.main.dateAssistTextFont,
        NSAttributedStringKey.backgroundColor: configuration.theme.markbgColor
      ]
      let maStr = String(format: "BOLL: ")
      drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))
      
      
      if let value = drawModel.BOLL_MB {
        let mbAttrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : configuration.theme.BOLL_MBColor,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        ]
        let mbAttrsStr = NSAttributedString(string: String(format: "  %.2f  ", value), attributes: mbAttrs)
        drawAttrsString.append(mbAttrsStr)
      }
      
      if let value = drawModel.BOLL_UP {
        let upAttrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : configuration.theme.BOLL_UPColor,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        ]
        let upAttrsStr = NSAttributedString(string: String(format: " %.2f  ", value), attributes: upAttrs)
        drawAttrsString.append(upAttrsStr)
      }
    
      if let value = drawModel.BOLL_DN {
        let dnAttrs: [NSAttributedStringKey : Any]? = [
          NSAttributedStringKey.foregroundColor : configuration.theme.BOLL_DNColor,
          NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        ]
        let dnAttrsStr = NSAttributedString(string: String(format: " %.2f  ", value), attributes: dnAttrs)
        drawAttrsString.append(dnAttrsStr)
      }
      
    default:
      break
    }
    drawAssistString = drawAttrsString
  }
}

// MARK: - 绘制指标
extension CBKLineMainView {
  
  /// 绘制MA指标
  ///
  /// - Parameters:
  ///   - context: contex
  ///   - limitValue: 极限值
  ///   - drawModels: 绘制的K线模型数据
  fileprivate func drawMA(context: CGContext,
                          limitValue: (minValue: Double, maxValue: Double),
                          drawModels: [CBKLineModel])
  {
    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
    
    switch configuration.main.indicatorType {
    case .MA(_):
      
      for (idx, type) in [CBBrushType.MA,  CBBrushType.MA2, CBBrushType.MA3].enumerated() {
        
        let maLineBrush = CBMALineBrush(brushType: type,
                                        context: context)
        
        maLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
          
          if let value = model.MAs?[idx] {
            
            let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
              self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
            
            let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
            
            return CGPoint(x: xPosition, y: yPosition)
          }
          return nil
        }
        maLineBrush.draw(drawModels: drawModels)
      }
      
    default:
      break
    }
  }
  
  /// 绘制EMA指标
  fileprivate func drawEMA(context: CGContext,
                           limitValue: (minValue: Double, maxValue: Double),
                           drawModels: [CBKLineModel])
  {
    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
    
    switch configuration.main.indicatorType {
    case .EMA(_):
      
      for (idx, type) in [CBBrushType.EMA, CBBrushType.EMA2].enumerated() {
        
        let emaLineBrush = CBMALineBrush(brushType: type,
                                         context: context)
        
        emaLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
          
          if let value = model.EMAs?[idx] {
            
            let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
              self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
            
            let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
            
            return CGPoint(x: xPosition, y: yPosition)
          }
          return nil
        }
        emaLineBrush.draw(drawModels: drawModels)
      }
    default:
      break
    }
  }
  
  /// 绘制BOLL指标
  fileprivate func drawBOLL(context: CGContext,
                            limitValue: (minValue: Double, maxValue: Double),
                            drawModels: [CBKLineModel])
  {
    let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)

    let MBLineBrush = CBLineBrush(indicatorType: .BOLL_MB, context: context)
    MBLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.BOLL_MB {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
          self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
        let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    MBLineBrush.draw(drawModels: drawModels)

    let UPLineBrush = CBLineBrush(indicatorType: .BOLL_UP, context: context)
    UPLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.BOLL_UP {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
          self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace
        let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    UPLineBrush.draw(drawModels: drawModels)

    let DNLineBrush = CBLineBrush(indicatorType: .BOLL_DN, context: context)
    DNLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in

      if let value = model.BOLL_DN {
        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace) +
          self.configuration.theme.klineWidth * 0.5 + self.configuration.theme.klineSpace

        let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
        return CGPoint(x: xPosition, y: yPosition)
      }
      return nil
    }
    DNLineBrush.draw(drawModels: drawModels)
  }
  
}

// MARK: - 获取相关数据
extension CBKLineMainView {
  /// 获取绘制主图所需的K线模型数据
  fileprivate func fetchMainDrawKLineModels() {
    
    guard configuration.dataSource.klineModels.count > 0 else {
      mainDrawKLineModels = nil
      return
    }
    
    switch configuration.main.indicatorType {
    case .MA(_):
      let maModel = CBMAModel(indicatorType: configuration.main.indicatorType,
                              klineModels: configuration.dataSource.klineModels)
      mainDrawKLineModels = maModel.fetchDrawMAData(drawRange: configuration.dataSource.drawRange)
      
    case .EMA(_):
      let emaModel = CBEMAModel(indicatorType: configuration.main.indicatorType,
                                klineModels: configuration.dataSource.klineModels)
      mainDrawKLineModels = emaModel.fetchDrawEMAData(drawRange: configuration.dataSource.drawRange)
    case .BOLL(_):
      let bollModel = CBBOLLModel(indicatorType: configuration.main.indicatorType,
                                  klineModels: configuration.dataSource.klineModels)
      mainDrawKLineModels = bollModel.fetchDrawBOLLData(drawRange: configuration.dataSource.drawRange)
    default:
      mainDrawKLineModels = configuration.dataSource.drawKLineModels
    }
  }
  
  fileprivate func fetchLimitValue() -> (minValue: Double, maxValue: Double)? {
    
    guard let mainDrawKLineModels = mainDrawKLineModels else {
      return nil
    }
    
    var minValue = mainDrawKLineModels[0].low
    var maxValue = mainDrawKLineModels[0].high
    
    // 先求K线数据的最大最小
    for model in mainDrawKLineModels {
      if model.low < minValue {
        minValue = model.low
      }
      if model.high > maxValue {
        maxValue = model.high
      }
      // 求指标数据的最大最小
      switch configuration.main.indicatorType {
      case .MA(_):
        if let MAs = model.MAs {
          for value in MAs {
            if let value = value {
              minValue = value < minValue ? value : minValue
              maxValue = value > maxValue ? value : maxValue
            }
          }
        }
      case .EMA(_):
        if let EMAs = model.EMAs {
          for value in EMAs {
            if let value = value {
              minValue = value < minValue ? value : minValue
              maxValue = value > maxValue ? value : maxValue
            }
          }
        }
      case .BOLL(_):
        if let value = model.BOLL_MB {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        
        if let value = model.BOLL_UP {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        if let value = model.BOLL_DN {
          minValue = value < minValue ? value : minValue
          maxValue = value > maxValue ? value : maxValue
        }
        
      default:
        break
      }
    }
    
    limitValueChanged?((minValue, maxValue))
    
    return (minValue, maxValue)
  }
  
}
