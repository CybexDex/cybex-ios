//
//  LockupAssetsViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints

import SwiftyJSON

class LockupAssetsViewController: BaseViewController {
    
    struct Define {
        static let sectionHeaderHeight: CGFloat = 44.0
    }
    
    @IBOutlet weak var tableView: UITableView!
    var coordinator: (LockupAssetsCoordinatorProtocol & LockupAssetsStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.startLoading()
        self.coordinator?.fetchLockupAssetsData(
            [UserManager.shared.keys!.activeKey!.address,
             UserManager.shared.keys!.activeKey!.compressed,
             UserManager.shared.keys!.activeKey!.uncompressed,
             UserManager.shared.keys!.ownerKey!.address,
             UserManager.shared.keys!.ownerKey!.compressed,
             UserManager.shared.keys!.ownerKey!.uncompressed,
             UserManager.shared.keys!.memoKey!.address,
             UserManager.shared.keys!.memoKey!.compressed,
             UserManager.shared.keys!.memoKey!.uncompressed])
    }
    
    func setupUI() {
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.localizedText = R.string.localizable.lockupAssetsTitle.key.localizedContainer()
        let cell = String.init(describing: LockupAssetsCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
    }
    
    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else {return}
            self.endLoading()
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

// MARK: UITableViewDataSource

extension LockupAssetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = coordinator!.state.data.value
        return data.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: LockupAssetsCell.self), for: indexPath) as? LockupAssetsCell else {
            return LockupAssetsCell()
        }
        let data = coordinator!.state.data.value
        
        cell.setup(data.datas[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: Define.sectionHeaderHeight))
        
        return lockupAssetsSectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Define.sectionHeaderHeight
    }
    
}

extension LockupAssetsViewController {
    @objc func clickLockupAssetsViewEvent(_ data: [String: Any]) {
        guard let indexPathData = data["data"] as? LockupAssteData  else {
            return
        }
        self.coordinator?.applyLockupAsset(indexPathData)
    }
}
