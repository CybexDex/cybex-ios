//
//  ETORecordListViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class ETORecordListViewController: BaseViewController {
    
    @IBOutlet weak var recordTableView: UITableView!
    var coordinator: (ETORecordListCoordinatorProtocol & ETORecordListStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.title = R.string.localizable.eto_records.key.localized()

        let nibString = R.nib.etoRecordCell.identifier
        recordTableView.register(UINib.init(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
        recordTableView.separatorStyle = .none
        recordTableView.estimatedRowHeight = 88
        recordTableView.estimatedSectionFooterHeight = 0
        recordTableView.estimatedSectionHeaderHeight = 0
        recordTableView.rowHeight = 88
        
        self.addPullToRefresh(recordTableView) {[weak self] (finish) in
            guard let `self` = self else { return }
            self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.manual))
        }
        
        self.addInfiniteScrolling(recordTableView) {[weak self] (finish) in
            guard let `self` = self else { return }
            self.coordinator?.switchPageState(PageState.loadMore(page: self.coordinator!.state.page.value + 1))
        }
    }
    
    func setupData() {
        
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
            self.endLoading()

            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))
                
            case .loading(let reason):
                if reason == .initialRefresh {
                    self.startLoading()
                }
                
            case .refresh(let type):
                self.recordTableView.footer?.resetNoMoreData()
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))
                self.coordinator?.fetchETORecord(1, reason: type.mapReason())
                
            case .loadMore(let page):
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))
                self.coordinator?.fetchETORecord(page, reason: PageLoadReason.manualLoadMore)
                
            case .noMore:
                self.stopInfiniteScrolling(self.recordTableView, haveNoMore: true)
                
            case .noData:
                self.view.showNoData(R.string.localizable.recode_nodata.key.localized(), icon: R.image.img_no_records.name)
                
            case .normal(let reason):
                self.view.hiddenNoData()
                
                if reason == PageLoadReason.manualLoadMore {
                    self.stopInfiniteScrolling(self.recordTableView, haveNoMore: false)
                }
                else if reason == PageLoadReason.manualRefresh {
                    self.stopPullRefresh(self.recordTableView)
                }
                
            case .error(let error, let reason):
                self.showToastBox(false, message: error.localizedDescription)
                
                if reason == PageLoadReason.manualLoadMore {
                    self.stopInfiniteScrolling(self.recordTableView, haveNoMore: false)
                }
                else if reason == PageLoadReason.manualRefresh {
                    self.stopPullRefresh(self.recordTableView)
                }
            }
        }).disposed(by: disposeBag)
        
        self.coordinator!.state.changeSet.asObservable().skip(1).subscribe(onNext: {[weak self] (changeset) in
            guard let `self` = self else { return }
            
            self.recordTableView.reload(using: changeset, with: UITableView.RowAnimation.fade) {[weak self] data in
                guard let `self` = self else { return }

                self.coordinator?.state.data.accept(data)
            }
        }).disposed(by: disposeBag)
        
    }
}

extension ETORecordListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator!.state.data.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibString = R.nib.etoRecordCell.identifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: nibString, for: indexPath) as! ETORecordCell
        
        if let model = self.coordinator?.state.data.value[indexPath.row] {
            cell.setup(model, indexPath: indexPath)
        }
        
        return cell
    }
}



extension ETORecordListViewController {
//    @objc func <#view#>DidClicked(_ data:[String: Any]) {
//        if let addressdata = data["data"] as? <#model#>, let view = data["self"] as? <#view#>  {
//
//        }
//    }
}

