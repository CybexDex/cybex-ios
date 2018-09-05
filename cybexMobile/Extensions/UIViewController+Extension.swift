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
        let vc = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil)
        vc.addAction(action)
        
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func addPullToRefresh(_ tableView : UITableView,callback:@escaping(((()->Void)?)->Void)){
        
        tableView.es.addPullToRefresh {
            callback({[weak self] in
                self?.stopPullRefresh(tableView)
            })
        }
        
    }
    
    func stopPullRefresh(_ tableView : UITableView) {
        tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
    }
    
    func addInfiniteScrolling(_ tableView : UITableView ,callback:@escaping(((Bool)->())?)->()){
        tableView.es.addInfiniteScrolling {
            
            callback({[weak self] isNoMoreData in
                self?.stopInfiniteScrolling(tableView, haveNoMore: isNoMoreData)
            })
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


