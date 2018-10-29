//
//  Asset.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class Bucket: HandyJSON, NSCopying {
  var id: String = ""

  var baseVolume: String = ""
  var quoteVolume: String = ""

  var highBase: String = ""
  var highQuote: String = ""
  var lowBase: String = ""
  var lowQuote: String = ""

  var openBase: String = ""
  var openQuote: String = ""
  var closeBase: String = ""
  var closeQuote: String = ""

  var open: TimeInterval = 0
  var base: String = ""
  var quote: String = ""
  var seconds: String = ""

  required init() {
  }

  func mapping(mapper: HelpingMapper) {
    mapper <<< id                   <-- ("id", ToStringTransform())
    mapper <<< baseVolume          <-- ("base_volume", ToStringTransform())
    mapper <<< quoteVolume         <-- ("quote_volume", ToStringTransform())
    mapper <<< highBase            <-- ("high_base", ToStringTransform())
    mapper <<< highQuote           <-- ("high_quote", ToStringTransform())
    mapper <<< lowBase             <-- ("low_base", ToStringTransform())
    mapper <<< lowQuote            <-- ("low_quote", ToStringTransform())
    mapper <<< openBase            <-- ("open_base", ToStringTransform())
    mapper <<< openQuote           <-- ("open_quote", ToStringTransform())
    mapper <<< closeBase           <-- ("close_base", ToStringTransform())
    mapper <<< closeQuote          <-- ("close_quote", ToStringTransform())
    mapper <<< open                 <-- ("key.open", DateIntervalTransform())
    mapper <<< base          <-- ("key.base", ToStringTransform())
    mapper <<< quote          <-- ("key.quote", ToStringTransform())
    mapper <<< seconds         <-- ("key.seconds", ToStringTransform())
  }

  func copy(with zone: NSZone? = nil) -> Any {
    let copy = Bucket.deserialize(from: self.toJSON())
    return copy ?? Bucket()
  }

  static func empty() -> Bucket {
    return Bucket()
  }

}

enum changeScope {
  case greater
  case less
  case equal

  func icon() -> UIImage {
    switch self {
    case .greater:
      return #imageLiteral(resourceName: "ic_arrow_green.pdf")
    case .less:
      return #imageLiteral(resourceName: "ic_arrow_red.pdf")
    case .equal:
      return #imageLiteral(resourceName: "ic_arrow_grey2.pdf")
    }
  }

  func color() -> UIColor {
    switch self {
    case .greater:
      return .turtleGreen
    case .less:
      return .reddish
    case .equal:
      return .coolGrey
    }
  }
}

struct BucketMatrix {
  var price: String = ""

  var asset: [Bucket]

  var baseVolumeOrigin: Double = 0

  var baseVolume: String = ""
  var quoteVolume: String = ""

  var high: String = ""
  var low: String = ""

  var change: String = ""
  var base: String = ""
  var quote: String = ""

  var incre: changeScope = .equal

  var icon: String = ""
  init(_ homebucket: HomeBucket) {
    self.asset = homebucket.bucket
    self.base = homebucket.base
    self.quote = homebucket.quote

    self.icon = AppConfiguration.ServerIconsBaseURLString + quote.replacingOccurrences(of: ".", with: "_") + "_grey.png"

    guard let last = self.asset.last else { return }

    let first = self.asset.first!

    let flip = homebucket.base != last.base

    let lastClosebaseAmount = flip ? Double(last.closeQuote)! : Double(last.closeBase)!
    let lastClosequoteAmount = flip ? Double(last.closeBase)! : Double(last.closeQuote)!

    let firstOpenbaseAmount = flip ? Double(first.openQuote)! : Double(first.openBase)!
    let firstOpenquoteAmount = flip ? Double(first.openBase)! : Double(first.openQuote)!

    let baseInfo = homebucket.baseInfo
    let quoteInfo = homebucket.quoteInfo

    let basePrecision = pow(10, baseInfo.precision.double)
    let quotePrecision = pow(10, quoteInfo.precision.double)

    let lastClosePrice = (lastClosebaseAmount / basePrecision) / (lastClosequoteAmount / quotePrecision)
    let firseOpenPrice = (firstOpenbaseAmount / basePrecision) / (firstOpenquoteAmount / quotePrecision)

    var highPriceCollection: [Double] = []
    var lowPriceCollection: [Double] = []

    for bucket in self.asset {
      let highBase = flip ? (Double(bucket.lowQuote)! / basePrecision) : (Double(bucket.highBase)! / basePrecision)
      let quoteBase = flip ? (Double(bucket.lowBase)! / quotePrecision) : (Double(bucket.highQuote)! / quotePrecision)
      highPriceCollection.append(highBase / quoteBase)

      let lowBase = flip ? (Double(bucket.highQuote)! / basePrecision) : (Double(bucket.lowBase)! / basePrecision)
      let lowQuote = flip ? (Double(bucket.highBase)! / quotePrecision) : (Double(bucket.lowQuote)! / quotePrecision)
      lowPriceCollection.append(lowBase / lowQuote)

    }

    let high = highPriceCollection.max()!
    let low = lowPriceCollection.min()!

    let now = Date().addingTimeInterval(-24 * 3600).timeIntervalSince1970

    let baseVolume = self.asset.filter({$0.open > now}).map {flip ? $0.quoteVolume : $0.baseVolume}.reduce(0) { (last, cur) -> Double in
      last + Double(cur)!
    } / basePrecision

    let quoteVolume = self.asset.filter({$0.open > now}).map {flip ? $0.baseVolume: $0.quoteVolume}.reduce(0) { (last, cur) -> Double in
      last + Double(cur)!
      } / quotePrecision

    self.baseVolumeOrigin = baseVolume
    self.baseVolume = baseVolume.suffixNumber(digitNum: 2)
    self.quoteVolume = quoteVolume.suffixNumber(digitNum: 2)

    self.high = high.formatCurrency(digitNum: baseInfo.precision)
    self.low = low.formatCurrency(digitNum: baseInfo.precision)

    self.price = lastClosePrice.formatCurrency(digitNum: baseInfo.precision)

    let change = (lastClosePrice - firseOpenPrice) * 100 / firseOpenPrice
    let percent = round(change * 100) / 100.0

    self.change = percent.formatCurrency(digitNum: 2, usesGroupingSeparator: false)

    if percent == 0 {
      self.incre = .equal
    } else if percent < 0 {
      self.incre = .less
    } else {
      self.incre = .greater
    }

  }

}

class DateIntervalTransform: TransformType {
  public typealias Object = Double
  public typealias JSON = String

  public init() {}

  open func transformFromJSON(_ value: Any?) -> Double? {
    if let time = value as? String {
      return time.dateFromISO8601?.timeIntervalSince1970
    }

    return nil
  }

  open func transformToJSON(_ value: Double?) -> String? {
    if let date = value {
      return Date(timeIntervalSince1970: date).iso8601
    }
    return nil
  }
}

class ToStringTransform: TransformType {
  public typealias Object = String
  public typealias JSON = String

  public init() {}

  open func transformFromJSON(_ value: Any?) -> String? {
    if let val = value as? Double {
      return val.description
    } else if let val = value as? String {
      return val
    } else if let val = value as? Int {
      return val.description
    }

    return nil
  }

  open func transformToJSON(_ value: String?) -> String? {
    if let val = value {
      return val
    }
    return nil
  }
}

extension Bucket: Equatable {
  static func ==(lhs: Bucket, rhs: Bucket) -> Bool {
    return lhs.id == rhs.id &&
        lhs.baseVolume == rhs.baseVolume &&
        lhs.quoteVolume == rhs.quoteVolume &&
        lhs.highBase == rhs.highBase &&
        lhs.highQuote == rhs.highQuote &&
        lhs.lowBase == rhs.lowBase &&
        lhs.lowQuote == rhs.lowQuote &&
        lhs.openBase == rhs.openBase &&
        lhs.openQuote == rhs.openQuote &&
        lhs.closeBase == rhs.closeBase &&
        lhs.closeQuote == rhs.closeQuote &&
        lhs.open == rhs.open &&
        lhs.base == rhs.base &&
        lhs.quote == rhs.quote &&
        lhs.seconds == rhs.seconds
  }
}
