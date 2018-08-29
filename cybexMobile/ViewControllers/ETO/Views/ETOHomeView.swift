//
//  ETOHomeView.swift
//  cybexMobile
//
//  Created DKM on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import FSPagerView
import TinyConstraints

@IBDesignable
class ETOHomeView: BaseView {
    enum Event:String {
        case ETOHomeViewDidClicked
        case ChangeNavigationBarEvent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageView: ETOHomeBannerView!
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        let cell_name = R.nib.etoProjectCell.name
        tableView.register(UINib.init(nibName: cell_name, bundle: nil), forCellReuseIdentifier: cell_name)
        createFSPagerView()
    }
    
    func createFSPagerView(){
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 191))
        self.tableView.tableHeaderView = containerView
        self.pageView = ETOHomeBannerView(frame: .zero)
        containerView.addSubview(self.pageView)
        self.pageView.edgesToSuperview(insets: TinyEdgeInsets.zero, priority: LayoutPriority.required, isActive: true, usingSafeArea: true)
        self.pageView.topToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive: false, usingSafeArea: false)
        containerView.layoutIfNeeded()
    }

    
    func setupSubViewEvent() {

    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETOHomeViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ETOHomeView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etoProjectCell.name, for: indexPath) as! ETOProjectCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 40))
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: self.width - 24, height: 40))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .steel
        label.locali = R.string.localizable.hot_project.key.localized()
        sectionView.addSubview(label)
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// 增加View里面
extension ETOHomeView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 判断滑动距离从而显示navigationBar的状态
        self.next?.sendEventWith(Event.ChangeNavigationBarEvent.rawValue, userinfo: ["contentOffSet":scrollView.contentOffset])
    }
}
