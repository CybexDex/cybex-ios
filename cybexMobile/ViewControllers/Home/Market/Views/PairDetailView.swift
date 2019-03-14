//
//  PairDetailView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class PairDetailView: UIView {
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var bulkingIcon: UIImageView!
    @IBOutlet weak var bulking: UILabel!
    @IBOutlet weak var baseVolume: UILabel!
    @IBOutlet weak var quoteVolume: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var detailDateView: PairDetailDateViewView!

    var baseName: String = ""
    var quoteName: String = ""

    var data: Any? {
        didSet {
            if let ticker = data as? Ticker {
                refreshViewWith(ticker)
            } else if let markets = data as? CBKLineModel {
                refreshViewWith(markets)
            }
        }
    }

    func refreshViewWith(_ ticker: Ticker) {
        detailDateView.isHidden = true
        self.openLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.closeLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.highLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.lowLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.baseVolume.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.quoteVolume.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
        self.openLabel.text = ""
        self.closeLabel.text = ""

        if ticker.latest == "0" {
            self.baseVolume.text = self.baseName + ": -"
            self.quoteVolume.text = self.quoteName + ":-"
            self.highLabel.text = "High: -"
            self.lowLabel.text = "Low: -"
            self.price.text = "-"
            self.bulking.text = "-"
            self.bulkingIcon.image = #imageLiteral(resourceName: "ic_arrow_grey2.pdf")
            self.bulking.textColor = #colorLiteral(red: 0.9999966025, green: 0.9999999404, blue: 0.9999999404, alpha: 0.5)
            return
        }

        guard let _ = appData.assetInfo[ticker.base], let _ = appData.assetInfo[ticker.quote] else {
            return
        }

        DispatchQueue.global().async {
            DispatchQueue.main.async {
                let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(Pair(base: ticker.base, quote: ticker.quote))

                
                self.baseVolume.text = self.baseName + ": " + ticker.baseVolume.suffixNumber(digitNum: AppConfiguration.amountPrecision)
                self.quoteVolume.text = self.quoteName + ": " + ticker.quoteVolume.suffixNumber(digitNum: AppConfiguration.amountPrecision)
                
                self.price.text = ticker.latest.formatCurrency(digitNum: tradePrecision.price)
                self.bulking.text = (ticker.incre == .greater ? "+" : "") + ticker.percentChange.formatCurrency(digitNum: AppConfiguration.percentPrecision) + "%"
                self.bulking.textColor = ticker.incre.color()
                self.bulkingIcon.image = ticker.incre.icon()
            }
        }
    }

    func refreshViewWith(_ model: CBKLineModel) {
        detailDateView.baseName = self.baseName
        detailDateView.quoteName = self.quoteName
        detailDateView.isHidden = false

//        var lineModels = CBConfiguration.sharedConfiguration.dataSource.drawKLineModels

        detailDateView.adapterModelToPairDetailDateViewView(model)

//        self.openLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        self.closeLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        self.highLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        self.lowLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        self.baseVolume.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        self.quoteVolume.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
//        
//        self.openLabel.text = "Open: " + model.open.string(digits: model.precision)
//        self.closeLabel.text = "Close: " + model.close.string(digits: model.precision)
//        self.highLabel.text = "High: " + model.high.string(digits: model.precision)
//        self.lowLabel.text = "Low: " + model.low.string(digits: model.precision)
//        
//        let base_volume_pair =  self.baseVolume.text!.components(separatedBy: ":")
//        self.baseVolume.text =  base_volume_pair[0] + ":" + model.volume.suffixNumber(digitNum: 2)
//        
//        let quote_volume_pair =  self.quoteVolume.text!.components(separatedBy: ":")
//        
//        self.quoteVolume.text = quote_volume_pair[0] + ":" + model.towardsVolume.suffixNumber(digitNum: 2)
    }

    fileprivate func setup() {

    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
