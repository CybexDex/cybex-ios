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
class ETOHomeView: CybexBaseView {
    enum Event: String {
        case eTOHomeViewDidClicked
        case changeNavigationBarEvent
    }

    var tableViewHeaderViewHeight: CGFloat {
        return 191
    }

    static let sectionHeight: CGFloat = 40
    @IBOutlet weak var tableView: UITableView!
    var pageView: ETOHomeBannerView!

    override var data: Any? {
        didSet {
            self.tableView.reloadData()
        }
    }
    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
        let cellName = R.nib.etoProjectCell.name
        tableView.register(UINib.init(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        createFSPagerView()
    }

    func createFSPagerView() {
        self.pageView = ETOHomeBannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tableViewHeaderViewHeight))
        self.tableView.tableHeaderView = self.pageView
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.eTOHomeViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }

    func createSectionHeight() -> UIView {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: ETOHomeView.sectionHeight))
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: self.width - 24, height: ETOHomeView.sectionHeight))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .steel
        label.locali = R.string.localizable.hot_project.key
        sectionView.addSubview(label)
        return sectionView
    }
}

extension ETOHomeView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datas = self.data as? [ETOProjectViewModel] {
            return datas.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etoProjectCell.name, for: indexPath) as? ETOProjectCell {
            cell.prepareForReuse()
            if let datas = self.data as? [ETOProjectViewModel] {
                cell.setup(datas[indexPath.row])
            }
            return cell
        }
        return ETOProjectCell()
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
