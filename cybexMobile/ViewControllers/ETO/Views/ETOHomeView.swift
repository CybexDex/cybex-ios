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
    enum Event:String {
        case ETOHomeViewDidClicked
        case ChangeNavigationBarEvent
    }
    var tableViewHeaderViewHeight : CGFloat {
        return Device.version() == .iPhoneX ? 240 : 191
    }
    static let section_height : CGFloat = 40
    @IBOutlet weak var tableView: UITableView!
    var pageView: ETOHomeBannerView!
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
        let cell_name = R.nib.etoProjectCell.name
        tableView.register(UINib.init(nibName: cell_name, bundle: nil), forCellReuseIdentifier: cell_name)
        createFSPagerView()
    }
    
    func createFSPagerView(){
        self.pageView = ETOHomeBannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tableViewHeaderViewHeight))
        self.tableView.tableHeaderView = self.pageView
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
        label.locali = R.string.localizable.hot_project.key
        sectionView.addSubview(label)
        return sectionView
    }
}

extension ETOHomeView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etoProjectCell.name, for: indexPath) as! ETOProjectCell
        cell.setup(ETOProjectModel())
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.createSectionHeight()
    }
}

//// 增加View里面
extension ETOHomeView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}
