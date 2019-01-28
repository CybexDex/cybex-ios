//
//  OrderPageTabViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/25.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class OrderPageTabViewController: SegmentedPagerTabStripViewController {
    var fillOrderOnly: Bool = false
    var pair: Pair?

    @IBOutlet weak var segmentLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var segmentRightMargin: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        let margin:CGFloat = fillOrderOnly ? 70 : 13
        segmentLeftMargin.constant = margin
        segmentRightMargin.constant = margin

        self.view.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        self.localizedText = R.string.localizable.openedTitle.key.localizedContainer()
    }

    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let vc2 = R.storyboard.business.myHistoryViewController()!
        let coordinator2 = MyHistoryCoordinator(rootVC: self.navigationController as! BaseNavigationController)
        vc2.coordinator = coordinator2
        vc2.type = fillOrderOnly ? .fillOrder(pair: pair!) : .fillOrder(pair: nil)

        let vc3 = R.storyboard.business.myHistoryViewController()!
        let coordinator3 = MyHistoryCoordinator(rootVC: self.navigationController as! BaseNavigationController)
        vc3.coordinator = coordinator3
        vc3.type = fillOrderOnly ? .groupFillOrder(pair: pair!) : .groupFillOrder(pair: nil)

        if fillOrderOnly {
            return [vc2, vc3]
        }

        let vc = R.storyboard.account.openedOrdersViewController()!
        vc.pageType = .account
        let coordinator = OpenedOrdersCoordinator(rootVC: self.navigationController as! BaseNavigationController)
        vc.coordinator = coordinator
        vc.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

        return [vc, vc2, vc3]

    }
}
