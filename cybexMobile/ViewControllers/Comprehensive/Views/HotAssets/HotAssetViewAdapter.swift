//
//  HotAssetViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension HotAssetView {
    func adapterModelToHotAssetView(_ model:HomeBucket) {
        assetName.text = model.quote_info.symbol.filterJade + "/" + model.base_info.symbol.filterJade
        let matrix = getCachedBucket(model)
        if model.bucket.count == 0 {
            amountLabel.text = "-"
            rmbLabel.text = "-"
            trendLabel.text = "-"
        }
        else {
            amountLabel.text = matrix.price
            amountLabel.textColor = matrix.incre.color()
            self.trendLabel.text = (matrix.incre == .greater ? "+" : "") + matrix.change.formatCurrency(digitNum: 2) + "%"
            self.trendLabel.textColor = matrix.incre.color()
            if let change = matrix.change.toDouble() ,change > 1000{
                self.trendLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
            }else{
                self.trendLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            }
            let (eth,cyb) = changeToETHAndCYB(model.quote_info.id)
            
            if eth.toDouble() == 0 && cyb.toDouble() == 0 {
                self.rmbLabel.text  = "-"
                
            }else if (eth == "0"){
                if let cyb_eth = changeCYB_ETH().toDouble(),cyb_eth != 0{
                    let eth_count = cyb.toDouble()! / cyb_eth
                    if eth_count * app_data.eth_rmb_price == 0{
                        self.rmbLabel.text  = "-"
                    }else{
                        self.rmbLabel.text  = "≈¥" + (eth_count * app_data.eth_rmb_price).formatCurrency(digitNum: 2)
                    }
                }else{
                    self.rmbLabel.text  = "-"
                }
            }else{
                if eth.toDouble()! * app_data.eth_rmb_price == 0 {
                    self.rmbLabel.text  = "-"
                }else{
                    self.rmbLabel.text  = "≈¥" + (eth.toDouble()! * app_data.eth_rmb_price).formatCurrency(digitNum: 2)
                }
            }
        }
        
        
        assetName.textAlignment = .center
        amountLabel.textAlignment = .center
        rmbLabel.textAlignment = .center
        trendLabel.textAlignment = .center
    }
}
