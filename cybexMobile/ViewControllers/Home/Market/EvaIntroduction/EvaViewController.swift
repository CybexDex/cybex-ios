//
//  EvaViewController.swift
//  cybexMobile
//
//  Created by KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class EvaViewController: BaseViewController {
    @IBOutlet weak var evaView: EvaView!
    
    override func viewDidLoad() {
        EvaService.request(target: EvaApi.projectInfo(name: "Ethereum", tokenName: "ETH"), success: { (json) in
            guard let evaProject = EvaProject.deserialize(from: json.dictionaryObject) else {
                return
            }
            self.evaView.adapterModelToEvaView(evaProject)
        }, error: { (error) in
            
        }) { (error) in
            
        }
    }

}
