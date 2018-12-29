//
//  EvaViewController.swift
//  cybexMobile
//
//  Created by KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability

class EvaViewController: BaseViewController {
    @IBOutlet weak var evaView: EvaView!
    var projectName: String?
    var tokenName: String?

    weak var parentVC: MarketViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        monitorNetwork()
        fetchData()
    }

    func monitorNetwork() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                self.fetchData()
            case .none:

                break
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func fetchData() {
        guard let projectName = projectName, let tokenName = tokenName else { return }

        EvaService.request(target: EvaApi.projectInfo(name: projectName, tokenName: tokenName), success: { (json) in
            guard let evaProject = EvaProject.deserialize(from: json.dictionaryObject) else {
                return
            }
            self.evaView.adapterModelToEvaView(evaProject)
        }, error: { (error) in

        }) { (error) in

        }
    }

}
