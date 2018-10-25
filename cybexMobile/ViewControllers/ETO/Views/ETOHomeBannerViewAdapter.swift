//
//  ETOHomeBannerViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ETOHomeBannerView {
    func adapterModelToETOHomeBannerView(_ model: [String]) {
        self.pagerControl.numberOfPages = model.count
        self.pagerControl.currentPage = 0
        if model.count < 2 {
            self.pagerView.automaticSlidingInterval = 0
        } else {
            self.pagerView.automaticSlidingInterval = 3
        }
        self.data = model
    }
}
