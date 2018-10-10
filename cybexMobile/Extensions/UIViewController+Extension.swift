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

extension UIViewController {
    @objc func refreshViewController() {//become active 后台到前台 或者double click tab
        
    }
    
    func showAlert(_ message:String, buttonTitle:String) {
        let vc = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil)
        vc.addAction(action)
        
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func addPullToRefresh(_ tableView : UITableView,callback:@escaping(((()->Void)?)->Void)){
        let headerView = tableView.es.addPullToRefresh {
            callback({[weak self] in
                self?.stopPullRefresh(tableView)
            })
        }
        
        if let headerview = ((headerView as ESRefreshHeaderView).animator as ESRefreshAnimatorProtocol).view as? ESRefreshHeaderAnimator {
            headerview.loadingDescription = R.string.localizable.loading.key.localized()
            headerview.releaseToRefreshDescription = R.string.localizable.releaseToRefresh.key.localized()
            headerview.pullToRefreshDescription = R.string.localizable.pullToRefresh.key.localized()
        }
        
    }
    
    func stopPullRefresh(_ tableView : UITableView) {
        tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
    }
    
    func addInfiniteScrolling(_ tableView : UITableView ,callback:@escaping(((Bool)->())?)->()){
         let footerView = tableView.es.addInfiniteScrolling {
            callback({[weak self] isNoMoreData in
                self?.stopInfiniteScrolling(tableView, haveNoMore: isNoMoreData)
            })
        }

        if let footerView = ((footerView as ESRefreshFooterView).animator as ESRefreshAnimatorProtocol).view as? ESRefreshFooterAnimator {
            footerView.loadingDescription = R.string.localizable.loading.key.localized()
            footerView.loadingMoreDescription = R.string.localizable.loadingMore.key.localized()
            footerView.noMoreDataDescription = R.string.localizable.noMoreData.key.localized()
        }
    }
    
    func stopInfiniteScrolling(_ tableView : UITableView, haveNoMore: Bool) {
        if haveNoMore {
            tableView.es.noticeNoMoreData()
        }
        else{
            tableView.es.stopLoadingMore()
        }
    }
}


