//
//  ETOProjectViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Fakery

extension ETOProjectView {
    func adapterModelToETOProjectView(_ model:ETOProjectModel) {
        let faker = Faker.init()
        self.icon.kf.setImage(with: URL(string: faker.company.logo()))
        self.nameLabel.text = faker.name.name()
        self.markLabel.text = faker.address.state()
        self.progressView.progress = Double(arc4random() % 100) * 0.01
        self.stateLabel.text = faker.address.state()
        self.progressLabel.text = "\(Double(arc4random() % 100) * 0.01)"
        self.timeLabel.text = faker.business.creditCardExpiryDate()?.dateString()
    }
}
