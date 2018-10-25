//
//  CBKLineBrush.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class CBLineBrush {

  public var indicatorType: CBIndicatorType
  private var context: CGContext
  private var firstValueIndex: Int?
  private let configuration = CBConfiguration.sharedConfiguration

  public var calFormula: ((Int, CBKLineModel) -> CGPoint?)?

  init(indicatorType: CBIndicatorType, context: CGContext) {
    self.indicatorType = indicatorType
    self.context = context

    context.setLineWidth(configuration.theme.indicatorLineWidth)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    switch indicatorType {
    case .DIF:
      context.setStrokeColor(configuration.theme.DIFColor.cgColor)
    case .DEA:
      context.setStrokeColor(configuration.theme.DEAColor.cgColor)
    case .BOLL_MB:
      context.setStrokeColor(configuration.theme.BOLL_MBColor.cgColor)
    case .BOLL_UP:
      context.setStrokeColor(configuration.theme.BOLL_UPColor.cgColor)
    case .BOLL_DN:
      context.setStrokeColor(configuration.theme.BOLL_DNColor.cgColor)
    default: break
    }
  }

  public func draw(drawModels: [CBKLineModel]) {

    for (index, model) in drawModels.enumerated() {

      if let point = calFormula?(index, model) {

        if firstValueIndex == nil {
          firstValueIndex = index
        }

        if firstValueIndex == index {
          context.move(to: point)
        } else {
          context.addLine(to: point)
        }
      }
    }
    context.strokePath()
  }
}
