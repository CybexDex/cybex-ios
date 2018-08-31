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
import Device

@IBDesignable
class ETOHomeView: BaseView {
    
    var tableViewHeaderViewHeight : CGFloat {
        return Device.version() == .iPhoneX ? 240 : 191
    }
    static let section_height : CGFloat = 40
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
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } 
        createFSPagerView()
    }
    
    func createFSPagerView(){
        let containerView = UIView(frame: .zero)
        self.tableView.tableHeaderView = containerView
        containerView.height(tableViewHeaderViewHeight)
        containerView.widthToSuperview()
        self.pageView = ETOHomeBannerView(frame: .zero)
        containerView.addSubview(self.pageView)
        self.pageView.edgesToSuperview(insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: LayoutPriority.required, isActive: true, usingSafeArea: false)
        containerView.layoutIfNeeded()
    }
    
    func setupSubViewEvent() {

    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETOHomeViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
    
    func createSectionHeight() -> UIView {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: ETOHomeView.section_height))
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: self.width - 24, height: ETOHomeView.section_height))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .steel
        label.locali = R.string.localizable.hot_project.key.localized()
        sectionView.addSubview(label)
        return sectionView
    }
    
    func fetchAlphaProgress() {
        let contentOffSet = tableView.contentOffset
        var progress : CGFloat = contentOffSet.y / tableViewHeaderViewHeight
        
        if progress < 0.05 {
            progress = 0
        }
        
        if progress > 0.5 {
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .always
            }
        }
        else {
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .never
            }
        }
        self.next?.sendEventWith(Event.ChangeNavigationBarEvent.rawValue, userinfo: ["progress" : progress])
    }
}

extension ETOHomeView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etoProjectCell.name, for: indexPath) as! ETOProjectCell
        cell.setup(ETOProjectModel())
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.createSectionHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ETOHomeView.section_height
    }
}

// 增加View里面
extension ETOHomeView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fetchAlphaProgress()
    }
}
