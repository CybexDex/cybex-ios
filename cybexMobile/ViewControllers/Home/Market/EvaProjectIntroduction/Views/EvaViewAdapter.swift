//
//  EvaViewAdapter.swift
//  cybexMobile
//
//  Created KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Kingfisher

extension EvaView {
    func adapterModelToEvaView(_ evaProject: EvaProject ) {
        evaIcon.kf.setImage(with: URL(string: evaProject.logo))
        projectName.text = evaProject.name
        projectDesc.text = evaProject.description
        scoreLabel.text = evaProject.score
        hypeScoreLabel.text = evaProject.hypeScore
        riskScoreLabel.text = evaProject.riskScore
        expectationLabel.text = evaProject.investmentRating
        
        if evaProject.platform.isEmpty {
            platformLabel.superview?.isHidden = true
        } else {
            platformLabel.text = evaProject.platform
        }
        
        if evaProject.industry.isEmpty {
            industryLabel.superview?.isHidden = true
        } else {
            industryLabel.text = evaProject.industry
        }
        
        if evaProject.icoTokenSupply.isEmpty {
            icoTokenSupplyLabel.superview?.isHidden = true
        } else {
            icoTokenSupplyLabel.text = evaProject.icoTokenSupply
        }
        
        if evaProject.tokenPriceInUsd.isEmpty {
            tokenPriceLabel.superview?.isHidden = true
        } else {
           tokenPriceLabel.text = evaProject.tokenPriceInUsd
        }
        
        if evaProject.country.isEmpty {
            countryLabel.superview?.isHidden = true
        } else {
            countryLabel.text = evaProject.country
        }
        
    
        projectDetails.text = evaProject.premium
    }
}
