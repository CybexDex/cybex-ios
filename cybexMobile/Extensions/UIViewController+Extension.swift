//
//  UIViewController+Extension.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ESPullToRefresh
import XLActionController
import SwiftTheme

extension UIViewController {
    @objc func refreshViewController() {//become active 后台到前台 或者double click tab
        
    }

    func showAlert(_ message: String, buttonTitle: String) {
        let vc = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil)
        vc.addAction(action)

        self.present(vc, animated: true, completion: nil)
    }

}

extension UIViewController {
    func addPullToRefresh(_ tableView: UITableView, callback:@escaping(((()->Void)?)->Void)) {
        let headerView = tableView.es.addPullToRefresh {
            callback({[weak self] in
                self?.stopPullRefresh(tableView)
            })
        }

        if let headerview = ((headerView as ESRefreshHeaderView).animator as ESRefreshAnimatorProtocol).view as? ESRefreshHeaderAnimator {
            headerview.loadingDescription = R.string.localizable.loading.key.localized()
            headerview.releaseToRefreshDescription = R.string.localizable.releaseToRefresh.key.localized()
            headerview.pullToRefreshDescription = R.string.localizable.pullToRefresh.key.localized()

            if let indicator = headerview.subviews.last as? UIActivityIndicatorView {
                indicator.style = ThemeManager.currentThemeIndex == 0 ? .white : .gray
            }
        }

    }

    func stopPullRefresh(_ tableView: UITableView) {
        tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
    }

    func addInfiniteScrolling(_ tableView: UITableView, callback:@escaping(((Bool)->Void)?)->Void) {
         let footerView = tableView.es.addInfiniteScrolling {
            callback({[weak self] isNoMoreData in
                self?.stopInfiniteScrolling(tableView, haveNoMore: isNoMoreData)
            })
        }

        if let footerView = ((footerView as ESRefreshFooterView).animator as ESRefreshAnimatorProtocol).view as? ESRefreshFooterAnimator {
            footerView.loadingDescription = R.string.localizable.loading.key.localized()
            footerView.loadingMoreDescription = R.string.localizable.loadingMore.key.localized()
            footerView.noMoreDataDescription = R.string.localizable.noMoreData.key.localized()
            if let indicator = footerView.subviews.last as? UIActivityIndicatorView {
                indicator.style = ThemeManager.currentThemeIndex == 0 ? .white : .gray
            }
        }
    }

    func stopInfiniteScrolling(_ tableView: UITableView, haveNoMore: Bool) {
        if haveNoMore {
            tableView.es.noticeNoMoreData()
        } else {
            tableView.es.stopLoadingMore()
        }
    }
}

// MARK: - PopOver
extension UIViewController {
    func updatePopOverViewCornerIfNeeded(_ r: CGFloat = 2) -> Bool {
        if r >= 0 && view.superview?.layer.cornerRadius != r {
            view.superview?.layer.cornerRadius = r
            return true
        }

        return false
    }


    func updateDimmingViewAlpha(_ alpha: CGFloat = 0) {
        let allSubViews: [UIView] = (UIApplication.shared.keyWindow?.subviews.last?.subviews)!

        for index in 0...allSubViews.count - 1 {
            if NSStringFromClass(allSubViews[index].classForCoder) == "UIDimmingView" {
                allSubViews[index].backgroundColor = UIColor.black.withAlphaComponent(alpha)
            }
        }
    }

    func removeDimmingViewMask() {
        let allSubViews: [UIView] = (UIApplication.shared.keyWindow?.subviews.last?.subviews)!

        for index in 0...allSubViews.count - 1 {
            if NSStringFromClass(allSubViews[index].classForCoder) == "_UIMirrorNinePatchView" {
                allSubViews[index].backgroundColor = UIColor.clear

                let arrayofImages = allSubViews[index].subviews as! [UIImageView]

                for imageIndex in 0...arrayofImages.count - 1 {
                    arrayofImages[imageIndex].image = nil
                }
            }
        }
    }
}


extension BaseViewController: UIPopoverPresentationControllerDelegate {
    func presentPopOverViewController(_ vc: UIViewController, size: CGSize, sourceView: UIView, offset: CGPoint, direction: UIPopoverArrowDirection, arrowColor: UIColor? = nil) {
        if let color = arrowColor {
            CybexPopoverBackgroundView.arrowColor = color
        }
        else {
            CybexPopoverBackgroundView.arrowColor = ThemeManager.currentThemeIndex == 0 ? UIColor.darkFour : UIColor.white
        }

        vc.preferredContentSize = size

        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.popoverBackgroundViewClass = CybexPopoverBackgroundView.self
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = CGRect(x: offset.x, y: offset.y, width: sourceView.width, height: sourceView.height)
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.permittedArrowDirections = direction
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        self.present(vc, animated: true)
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
