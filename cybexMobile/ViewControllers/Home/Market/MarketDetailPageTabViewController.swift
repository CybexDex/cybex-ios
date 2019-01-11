//
//  MarketDetailPageTabViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/4.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class MarketDetailPageTabViewController: ButtonBarPagerTabStripViewController {
    var pair: Pair!
    var rootNav: BaseNavigationController!
    
    override func viewDidLoad() {
        self.containerView.isScrollEnabled = false

        settings.style.selectedBarBackgroundColor = UIColor.pastelOrange
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.steel
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemBackgroundColor = UIColor.clear

        changeCurrentIndexProgressive = { (
            oldCell:ButtonBarViewCell?,
            newCell: ButtonBarViewCell?,
            progressPercentage: CGFloat,
            changeCurrentIndex: Bool,
            animated: Bool) -> Void in
                guard changeCurrentIndex == true else { return }
                oldCell?.label.textColor = UIColor.steel
                newCell?.label.textColor = UIColor.pastelOrange
        }
        super.viewDidLoad()
    }

    func updateMarketListHeight(_ height: CGFloat) {
        if let vc = rootNav.viewControllers[rootNav.viewControllers.count - 1] as? MarketViewController, vc.pageContentViewHeight != nil {
            vc.pageContentViewHeight.constant = height
        }
    }

    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let vc = R.storyboard.main.orderBookViewController()!
        vc.pair = pair
        let coordinator = OrderBookCoordinator(rootVC: rootNav)
        vc.coordinator = coordinator
        vc.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

        let vc2 = R.storyboard.main.tradeHistoryViewController()!
        vc2.pair = pair
        let coordinator2 = TradeHistoryCoordinator(rootVC: rootNav)
        vc2.coordinator = coordinator2
        vc2.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

        refreshChildViewController([vc, vc2], pair: pair)

        if isExistProjectIntroduction(pair) {
            let vc3 = R.storyboard.eva.evaViewController()!
            vc3.containerViewController = self
            vc3.tokenName = pair.quote.symbol

            if let projectName = AssetConfiguration.shared.quoteToProjectNames.value[pair.quote.symbol], !projectName.isEmpty {
                vc3.projectName = projectName
            }
            vc3.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

            return [vc, vc2, vc3]
        }
        else {
            return [vc, vc2]
        }
    }

    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair) {
        for vc in vcs {
            if let vc = vc as? TradeHistoryViewController {
                vc.refresh()
            }
        }
    }

    func isExistProjectIntroduction(_ pair: Pair) -> Bool {
        if let projectName = AssetConfiguration.shared.quoteToProjectNames.value[pair.quote.symbol], !projectName.isEmpty {
            return true
        }

        return false
    }
}
