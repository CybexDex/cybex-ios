//
//  KLineConfiguration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum CBKLineType: Int {
    case KLine // K线
    case timeLine // 分时图
    case other // 其他
}

/// 指标种类
enum CBIndicatorType {
    case NONE
    case MA([Int])
    case MAVolume([Int])
    case EMA([Int])
    case EMAVolume([Int])
    case DIF, DEA, MACD
    case KDJ, kdjK, kdjD, kdjJ
    case BOLL(Int), bollMB, bollUp, bollDN
    case RSI
    case VOL
    case DMI
}

/// 时间线分隔
enum CBTimeLineType: Int {
    case fiveMinute = 300 // 5分
    case oneHour = 3600 // 1小时
    case oneDay = 86400 // 1天
}

public final class CBConfiguration {
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        theme = BlackKLineTheme()
    }

    static let sharedConfiguration = CBConfiguration()

    var themeIndex: Int = 0

    // MARK: - Common

    var dateFormatter: DateFormatter

    let dataSource: CBDataSource = CBDataSource()

    /// 全局主题
    var theme: CBTheme

    /// 主图Configuration(main)
    let main: CBMainConfiguration = CBMainConfiguration()

    /// 成交量图Configuration(volume)
    let volume: CBVolumeConfiguration = CBVolumeConfiguration()

    /// 指标图Configuration(accessory)
    let accessory: CBAccessoryConfiguration = CBAccessoryConfiguration()
}

class CBDataSource {
    var drawRange: NSRange?
    var klineModels = [CBKLineModel]()
    var drawKLineModels = [CBKLineModel]()
}

protocol CBTheme {

    // MARK: K线主题

    /// 涨的颜色
    var increaseColor: UIColor { get }

    /// 跌的颜色
    var decreaseColor: UIColor { get }

    /// k线的间隔
    var klineSpace: CGFloat { get }

    /// k线图主体宽度
    var klineWidth: CGFloat { get set }
    /// 上下影线宽度
    var klineShadowLineWidth: CGFloat { get }

    var klineRadius: CGFloat { get }

    /// k线最大宽度
    var klineMaxWidth: CGFloat { get }

    /// k线最小宽度
    var klineMinWidth: CGFloat { get }

    /// k线缩放界限
    var klineScale: CGFloat { get }

    /// k线缩放因子
    var klineScaleFactor: CGFloat { get }

    /// 指标线宽度
    var indicatorLineWidth: CGFloat { get }

    /// 十字线颜色
    var longPressLineColor: UIColor { get set }

    /// 十字线宽度
    var longPressLineWidth: CGFloat { get }

    /// 刻度线宽度
    var tickWidth: CGFloat { get }

    /// 刻度线颜色
    var tickColor: UIColor { get set }

    var dashWidth: CGFloat { get }

    var dashColor: UIColor { get set }

    // MARK: 指标颜色

    var markColor: UIColor { get }
    var markbgColor: UIColor { get }

    var MA1: UIColor { get }
    var MA2: UIColor { get }
    var MA3: UIColor { get }

    var EMA1: UIColor { get }
    var EMA2: UIColor { get }

    var DIFColor: UIColor { get }
    var DEAColor: UIColor { get }
    var MACDColor: UIColor { get }

    var bollMBColor: UIColor { get }
    var bollUPColor: UIColor { get }
    var bollDNColor: UIColor { get }
    var bollFillColor: UIColor { get }
}

public class CBMainConfiguration {
    /// 主图图表的背景色
    var backgroundColor = UIColor.clear

    /// 主图比例
    var scale: CGFloat = 0.50

    /// 主图顶部提示信息高度
    var assistViewHeight: CGFloat = 25.0

    /// 主图时间线信息高度
    var dateAssistViewHeight: CGFloat = 14.0

    // 最大值 最小值高度
    var valueAssistViewHeight: CGFloat = 14.0

    /// 时间线
    var timeLineType: CBTimeLineType = .oneDay

    /// 主图K线类型
    var klineType: CBKLineType = .KLine

    /// 主图指标类型
    var indicatorType: CBIndicatorType = .MA([7, 25, 99])

    /// 辅助视图背景色(e.g. 日期的背景色)
    var dateAssistViewBgColor = #colorLiteral(red: 0.08267984539, green: 0.1148783937, blue: 0.1728201807, alpha: 1)

    /// 辅助视图字体颜色(e.g. 日期的字体颜色)
    var dateAssistTextColor = #colorLiteral(red: 0.4705882668, green: 0.5058823228, blue: 0.6039215922, alpha: 0.3000000119)

    // 最大值最小值字体
    var valueAssistTextColor = #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1)
    var valueAssistTextFont = UIFont.systemFont(ofSize: 10)

    /// 辅助视图字体大小(e.g. 日期的字体大小)
    var dateAssistTextFont = UIFont.systemFont(ofSize: 10)
}

class BlackKLineTheme: CBTheme {
    var increaseColor: UIColor = #colorLiteral(red: 0.4922918081, green: 0.7674361467, blue: 0.356476903, alpha: 1)

    var decreaseColor: UIColor = #colorLiteral(red: 0.7984321713, green: 0.3588138223, blue: 0.2628142834, alpha: 1)

    var klineSpace: CGFloat = 5

    var klineWidth: CGFloat = 5

    var klineRadius: CGFloat = 0.5

    var klineShadowLineWidth: CGFloat = 1

    var klineMaxWidth: CGFloat = 20

    var klineMinWidth: CGFloat = 0.3

    var klineScale: CGFloat = 0.03

    var klineScaleFactor: CGFloat = 0.03

    var indicatorLineWidth: CGFloat = 1

    var longPressLineColor: UIColor = #colorLiteral(red: 0.9689999819, green: 0.97299999, blue: 0.9800000191, alpha: 1)

    var longPressLineWidth: CGFloat = 0.5

    var tickWidth: CGFloat = 1

    var tickColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    var dashWidth: CGFloat = 1

    var dashColor: UIColor = #colorLiteral(red: 0.9999966025, green: 0.9999999404, blue: 0.9999999404, alpha: 0.16)

    var markColor: UIColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
    var markbgColor: UIColor = #colorLiteral(red: 0.9999966025, green: 0.9999999404, blue: 0.9999999404, alpha: 0.05999999866)

    var MA1: UIColor = #colorLiteral(red: 0.2071067393, green: 0.528085351, blue: 0.4991607666, alpha: 1)

    var MA2: UIColor = #colorLiteral(red: 0.4551945925, green: 0.3369303346, blue: 0.6112034917, alpha: 1)

    var MA3: UIColor = #colorLiteral(red: 0.1757248342, green: 0.4277485609, blue: 0.2173056602, alpha: 1)

    var EMA1: UIColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)

    var EMA2: UIColor = #colorLiteral(red: 0.5100696087, green: 0.3246001303, blue: 0.1657423973, alpha: 1)

    var DIFColor: UIColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)

    var DEAColor: UIColor = #colorLiteral(red: 0.5100696087, green: 0.3246001303, blue: 0.1657423973, alpha: 1)

    var MACDColor: UIColor = #colorLiteral(red: 0.302782774, green: 0.4453626275, blue: 0.7515279055, alpha: 1)

    var bollMBColor: UIColor = #colorLiteral(red: 0.6275084615, green: 0.2648866773, blue: 0.2499080598, alpha: 1)

    var bollUPColor: UIColor = #colorLiteral(red: 0.302782774, green: 0.4453626275, blue: 0.7515279055, alpha: 1)

    var bollDNColor: UIColor = #colorLiteral(red: 0.302782774, green: 0.4453626275, blue: 0.7515279055, alpha: 1)

    var bollFillColor: UIColor = #colorLiteral(red: 0.4470589161, green: 0.5843137503, blue: 0.9921568036, alpha: 0.05999999866)
}

public class CBVolumeConfiguration {
    /// 是否显示成交量视图
    var show: Bool = true

    /// 成交量视图背景色
    var backgroundColor = UIColor.clear

    /// 成交量比例
    var scale: CGFloat = 0.25

    /// 顶部提示信息高度
    var topViewHeight: CGFloat = 20.0

    /// 成交量图分时线宽度
    var lineWidth: CGFloat = 0.5

    /// 成交量指标类型
    var indicatorType: CBIndicatorType = .EMAVolume([12, 26])
}

// MARK: - 指标图Configuration(accessory)

public class CBAccessoryConfiguration {
    /// 是否显示指标图
    var show: Bool = true

    /// 指标视图背景色
    var backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1)]

    /// 指标图比例
    var scale: CGFloat = 0.25

    /// 顶部提示信息高度
    var topViewHeight: CGFloat = 20.0

    /// 指标图分时线宽度
    var lineWidth: CGFloat = 0.5

    /// 辅助图指标类型
    var indicatorType: CBIndicatorType = .MACD
}
