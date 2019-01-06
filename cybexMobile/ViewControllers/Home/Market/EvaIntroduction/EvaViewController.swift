//
//  EvaViewController.swift
//  cybexMobile
//
//  Created by KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability
import XLPagerTabStrip

class EvaViewController: BaseViewController {
    @IBOutlet weak var evaView: EvaView!
    var projectName: String?
    var tokenName: String?

    var containerViewController: MarketDetailPageTabViewController?
    var data: EvaProject?

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

        self.refreshView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    func refreshView() {
        guard let model = data else { return }
        self.evaView.adapterModelToEvaView(model)
        self.evaView.updateHeight()
        self.containerViewController?.updateMarketListHeight(self.evaView.heightWithSafeAreaTop + 76)
    }

    func fetchData() {
        guard let projectName = projectName, let tokenName = tokenName else { return }

        EvaService.request(target: EvaApi.projectInfo(name: projectName, tokenName: tokenName), success: { (json) in
            guard let evaProject = EvaProject.deserialize(from: json.dictionaryObject) else {
                return
            }
            self.data = evaProject
            if self.isVisible {
                self.refreshView()
            }
        }, error: { (error) in

        }) { (error) in

        }
    }

}

extension EvaViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: R.string.localizable.eva_title_introduction.key.localized())
    }
}
