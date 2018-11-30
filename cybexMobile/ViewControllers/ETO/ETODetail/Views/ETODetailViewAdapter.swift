//
//  ETODetailViewAdapter.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift

extension ETODetailView {
    func adapterModelToETODetailView(_ model: ETOProjectViewModel) {
        if let data = model.projectModel {
            if Localize.currentLanguage() == "en" {
                if data.addsDetail.count != 0 {
                    websiteView.setContentAttribute(contentLabelStr: model.projectWebsite, attLabelArray: [data.addsWebsite, data.addsWhitepaper, data.addsDetail])
                } else {
                    websiteView.setContentAttribute(contentLabelStr: model.projectWebsite, attLabelArray: [data.addsWebsite, data.addsWhitepaper])
                }
                introView.content = data.addsAdvantageLangEn
            } else {

                if data.addsDetail.count != 0 {
                   websiteView.setContentAttribute(contentLabelStr: model.projectWebsiteEn, attLabelArray: [data.addsWebsiteLangEn, data.addsWhitepaperLangEn, data.addsDetailLangEn])
                } else {
                    websiteView.setContentAttribute(contentLabelStr: model.projectWebsite, attLabelArray: [data.addsWebsiteLangEn, data.addsWhitepaperLangEn])
                }

                introView.content = data.addsAdvantage
            }
            if data.addsWhitelist == "" && data.addsWhitelistLangEn == "" {
                self.getWhiteListView.isHidden = true
            }
        }
        detailView.content = model.etoDetail
        headerView.adapterModelToETODetailHeaderView(model)
    }
}
