//
//  CBMALineBrush.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum CBBrushType {
    case MA
    case MA2
    case MA3

    case EMA
    case EMA2
    case EMA3

}

class CBMALineBrush {

    public var calFormula: ((Int, CBKLineModel) -> CGPoint?)?
    public var brushType: CBBrushType
    private var context: CGContext
    private var firstValueIndex: Int?
    private let configuration = CBConfiguration.sharedConfiguration

    init(brushType: CBBrushType, context: CGContext) {
        self.brushType = brushType
        self.context = context

        context.setLineWidth(configuration.theme.indicatorLineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        switch brushType {
        case .MA:
            context.setStrokeColor(configuration.theme.MA1.cgColor)
        case .MA2:
            context.setStrokeColor(configuration.theme.MA2.cgColor)
        case .MA3:
            context.setStrokeColor(configuration.theme.MA3.cgColor)
        case .EMA:
            context.setStrokeColor(configuration.theme.EMA1.cgColor)
        case .EMA2:
            context.setStrokeColor(configuration.theme.EMA2.cgColor)
        case .EMA3:
            context.setStrokeColor(configuration.theme.EMA3.cgColor)
        }
    }

    func draw(drawModels: [CBKLineModel]) {

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
