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
    func adapterModelToETODetailView(_ model:ETOProjectViewModel) {
        if let data = model.projectModel {
            if Localize.currentLanguage() == "en" {
                websiteView.setContentAttribute(contentLabelStr: model.project_website, attLabelArray: [data.adds_website, data.adds_whitepaper, data.adds_detail])
                introView.content = data.adds_advantage__lang_en
            }
            else {
                websiteView.setContentAttribute(contentLabelStr: model.project_website_en, attLabelArray: [data.adds_website__lang_en, data.adds_whitepaper__lang_en, data.adds_detail__lang_en])
                introView.content = data.adds_advantage
            }
            if data.adds_whitelist == "" && data.adds_whitelist__lang_en == "" {
                self.getWhiteListView.isHidden = true
            }
        }
        detailView.content = model.etoDetail
        headerView.adapterModelToETODetailHeaderView(model)
    }
}
