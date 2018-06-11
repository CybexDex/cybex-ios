//
//  CBKLineDrawView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints

class CBKLineDrawView: UIView {

    // MARK: - Property

    fileprivate let configuration = CBConfiguration.sharedConfiguration

    fileprivate let drawValueViewWidth: CGFloat = 0

    fileprivate var mainView: CBKLineMainView!
    fileprivate var volumeView: CBKLineVolumeView!
    fileprivate var accessoryView: CBKLineAccessoryView!

    fileprivate var indicatorVerticalView: UIView!
    fileprivate var indicatorHorizontalView: UIView!

    fileprivate var lastScale: CGFloat = 1.0
    fileprivate var lastPanPoint: CGPoint?
    fileprivate var lastOffsetIndex: Int?

    var horizantalTop: Constraint!
    var verticalLeft: Constraint!

    var panGesture: UIPanGestureRecognizer!
    /// 开始draw的数组下标
    fileprivate var drawStartIndex: Int?

    var accessoryHeight: Constraint!

    /// draw的个数
    fileprivate var drawCount: Int {
        let count = Int((bounds.width - drawValueViewWidth) / (configuration.theme.klineSpace + configuration.theme.klineWidth))

        if count <= 0 {
            return configuration.dataSource.klineModels.count
        }

        return count > configuration.dataSource.klineModels.count ? configuration.dataSource.klineModels.count : count
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 捏合手势
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        addGestureRecognizer(pinchGesture)
        // 长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        addGestureRecognizer(longPressGesture)
        // 移动手势
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        panGesture.require(toFail: AppConfiguration.shared.appCoordinator.curDisplayingCoordinator().rootVC.interactivePopGestureRecognizer!)

        loadingSubviews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func drawKLineView(_ initialize: Bool = true) {
        fetchDrawModels()

        if initialize {
            drawStartIndex = nil
            lastOffsetIndex = nil
        }

        mainView.drawMainView()
        volumeView.drawVolumeView()
        accessoryView.drawAccessoryView()
    }

    func switchToAccessory(_ showaccessory: Bool) {
        if showaccessory {
            accessoryHeight.constant = 40
        } else {
            accessoryHeight.constant = 0
        }
    }

    private func fetchDrawModels() {
        // 展示的个数

        if drawStartIndex == nil {
            drawStartIndex = configuration.dataSource.klineModels.count - drawCount - 1
        }

        if lastOffsetIndex != nil {
            drawStartIndex! -= lastOffsetIndex!
        }

        drawStartIndex! = drawStartIndex! > 0 ? drawStartIndex! : 0
        if drawStartIndex! > configuration.dataSource.klineModels.count - drawCount - 1 {
            drawStartIndex! = configuration.dataSource.klineModels.count - drawCount - 1
        }

        configuration.dataSource.drawKLineModels.removeAll()

        let loc = drawStartIndex! > 0 ? drawStartIndex! : 0

        configuration.dataSource.drawKLineModels = Array(configuration.dataSource.klineModels[loc ..< loc + drawCount])

        configuration.dataSource.drawRange = NSMakeRange(loc, drawCount)
    }
}

extension CBKLineDrawView {
    func parentScrollView() -> UIScrollView {
        var scrollView: UIScrollView!

        var curView: UIView = self
        while let parentView = curView.superview {
            if parentView.isKind(of: UIScrollView.self) {
                scrollView = parentView as! UIScrollView
                break
            }
            curView = parentView
        }

        return scrollView
    }

    fileprivate func loadingSubviews() {
        loadingIndicator()

        loadingAccessoryView()
        loadingVolumeView()
        loadingMainView()
    }

    private func loadingMainView() {
        /// Main View
        mainView = CBKLineMainView()
        mainView.backgroundColor = UIColor.clear
        mainView.limitValueChanged = { (_: (minValue: Double, maxValue: Double)?) -> Void in
//      if let limitValue = limitValue {
//        self?.mainValueView.limitValue = limitValue
//      }
        }
        addSubview(mainView)

        mainView.top(to: self)
        mainView.left(to: self)
        mainView.right(to: self)
        mainView.bottomToTop(of: volumeView)

        /// Main Value View
    }

    private func loadingVolumeView() {
        /// Volume View
        volumeView = CBKLineVolumeView()
        volumeView.backgroundColor = UIColor.clear

        volumeView.limitValueChanged = { (_: (minValue: Double, maxValue: Double)?) -> Void in
//      if let limitValue = limitValue {
//      }
        }
        addSubview(volumeView)

        volumeView.left(to: self)
        volumeView.right(to: self)
        volumeView.bottomToTop(of: accessoryView)
        volumeView.height(40)
    }

    private func loadingAccessoryView() {
        /// Accessory View
        accessoryView = CBKLineAccessoryView()
        accessoryView.backgroundColor = UIColor.clear

        accessoryView.limitValueChanged = { (_: (minValue: Double, maxValue: Double)?) -> Void in
//      if let limitValue = limitValue {
//      }
        }
        addSubview(accessoryView)
        accessoryView.bottom(to: self)
        accessoryView.left(to: self)
        accessoryView.right(to: self)
        accessoryHeight = accessoryView.height(0)
    }

    private func loadingIndicator() {
        /// 指示器
        indicatorVerticalView = UIView()
        indicatorVerticalView.isHidden = true
        indicatorVerticalView.backgroundColor = configuration.theme.longPressLineColor
        addSubview(indicatorVerticalView)

        verticalLeft = indicatorVerticalView.left(to: self, offset: 0)
        indicatorVerticalView.width(configuration.theme.longPressLineWidth)
        indicatorVerticalView.top(to: self)
        indicatorVerticalView.bottom(to: self)

        indicatorHorizontalView = UIView()
        indicatorHorizontalView.isHidden = true
        indicatorHorizontalView.backgroundColor = configuration.theme.longPressLineColor
        addSubview(indicatorHorizontalView)

        indicatorHorizontalView.left(to: self)
        indicatorHorizontalView.height(configuration.theme.longPressLineWidth)
        indicatorHorizontalView.right(to: self)
        horizantalTop = indicatorHorizontalView.top(to: self, offset: 0)
    }
}

extension CBKLineDrawView {
    /// 移动手势
    /// 左 -> 右 : x递增, x > 0
    /// 右 -> 左 : x递减, x < 0
    /// - Parameter recognizer: UIPanGestureRecognizer
    @objc
    fileprivate func panGestureAction(_ recognizer: UIPanGestureRecognizer) {
        if indicatorVerticalView.isHidden == false {
            lastOffsetIndex = nil
            lastPanPoint = nil

            return
        }

        switch recognizer.state {
        case .began:
            lastPanPoint = recognizer.location(in: recognizer.view)
        case .changed:

            let location = recognizer.location(in: recognizer.view)
            let klineUnit = configuration.theme.klineWidth + configuration.theme.klineSpace

            if abs(location.x - lastPanPoint!.x) < klineUnit {
                return
            }

            lastOffsetIndex = Int((location.x - lastPanPoint!.x) / klineUnit)

            drawKLineView(false)
            // 记录上次点
            lastPanPoint = location

        case .ended:

            lastOffsetIndex = nil
            lastPanPoint = nil

        default: break
        }
    }

    // MARK: 捏合手势

    /// 捏合手势
    /// 内 -> 外: recognizer.scale 递增, 且recognizer.scale > 1.0
    /// 外 -> 内: recognizer.scale 递减, 且recognizer.scale < 1.0
    /// - Parameter recognizer: UIPinchGestureRecognizer
    @objc
    fileprivate func pinchAction(_ recognizer: UIPinchGestureRecognizer) {
        let difValue = recognizer.scale - lastScale

        if abs(difValue) > configuration.theme.klineScale {
            let lastKLineWidth: CGFloat = configuration.theme.klineWidth
            let newKLineWidth: CGFloat = configuration.theme.klineWidth * (difValue > 0 ?
                (1 + configuration.theme.klineScaleFactor) : (1 - configuration.theme.klineScaleFactor))

            // 超过限制 不在绘制
            if newKLineWidth > configuration.theme.klineMaxWidth || newKLineWidth < configuration.theme.klineMinWidth {
                return
            }

            configuration.theme.klineWidth = newKLineWidth
            lastScale = recognizer.scale

            if recognizer.numberOfTouches == 2 {
                let pinchPoint1 = recognizer.location(ofTouch: 0, in: recognizer.view)
                let pinchPoint2 = recognizer.location(ofTouch: 1, in: recognizer.view)

                let centerPoint = CGPoint(x: (pinchPoint1.x + pinchPoint2.x) * 0.5,
                                          y: (pinchPoint1.y + pinchPoint2.y) * 0.5)

                let lastOffsetCount = Int(centerPoint.x / (configuration.theme.klineSpace + lastKLineWidth))
                let newOffsetCount = Int(centerPoint.x / (configuration.theme.klineSpace + configuration.theme.klineWidth))

                lastOffsetIndex = newOffsetCount - lastOffsetCount
            }
            drawKLineView(false)
            lastOffsetIndex = nil
        }
    }

    // MARK: 长按手势

    @objc
    fileprivate func longPressAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let location: CGPoint = recognizer.location(in: recognizer.view)

            if location.x <= drawValueViewWidth { return }

            let unit = configuration.theme.klineWidth + configuration.theme.klineSpace

            let offsetCount: Int = Int((location.x - drawValueViewWidth) / unit)
            let previousOffset: CGFloat = CGFloat(offsetCount) * unit + configuration.theme.klineWidth / 2.0 - configuration.theme.klineShadowLineWidth / 2.0 + drawValueViewWidth
            let nextOffset: CGFloat = CGFloat(offsetCount + 1) * unit + configuration.theme.klineWidth / 2.0 - configuration.theme.klineShadowLineWidth / 2.0 + drawValueViewWidth

            /// 显示十字线
            indicatorVerticalView.isHidden = false
            indicatorHorizontalView.isHidden = false

            var drawModel: CBKLineModel?

            horizantalTop.constant = location.y
            indicatorHorizontalView.layoutIfNeeded()

            if abs(previousOffset - location.x) < abs(nextOffset - location.x) {
                verticalLeft.constant = previousOffset
                indicatorVerticalView.layoutIfNeeded()

                if configuration.dataSource.drawKLineModels.count > offsetCount {
                    drawModel = configuration.dataSource.drawKLineModels[offsetCount]
                }

            } else {
                verticalLeft.constant = nextOffset
                indicatorVerticalView.layoutIfNeeded()

                if configuration.dataSource.drawKLineModels.count > offsetCount + 1 {
                    drawModel = configuration.dataSource.drawKLineModels[offsetCount + 1]
                }
            }

            if let limitValue = mainView.fetchLimitValue(), let model = drawModel {
                let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(mainView.drawHeight)

                horizantalTop.constant = abs(mainView.drawMaxY - CGFloat((model.close - limitValue.minValue) / unitValue))

                mainView.fetchAssistString(model: model)
                mainView.setNeedsDisplay()
            }

        } else if recognizer.state == .ended {
            // 隐藏十字线
            indicatorVerticalView.isHidden = true
            indicatorHorizontalView.isHidden = true
            mainView.fetchAssistString(model: nil)
            mainView.setNeedsDisplay()
        }
    }
}

extension CBKLineDrawView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)

            return fabs(velocity.y) < fabs(velocity.x)
        }

        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
