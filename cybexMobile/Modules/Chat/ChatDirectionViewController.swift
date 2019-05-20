//
//  ChatDirectionViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift


protocol ChatDirectionViewControllerDelegate {
    func clicked(_ sender: ChatDirectionViewController)
}

class ChatDirectionViewController: BaseViewController {
    
    enum ChatDirectionType: Int {
        case icon = 0
        case newMessage
    }
    
    var delegate: ChatDirectionViewControllerDelegate?
    
    var contentView: UIView?
    
    var viewType: ChatDirectionType = .icon
    
    var name: String = ""
    var coordinator: (ChatDirectionCoordinatorProtocol & ChatDirectionStateManagerProtocol)?
    private(set) var context: ChatDirectionContext?
    
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
        switch viewType {
        case .icon:
            let iconView = ChatDirectionIconView()
            iconView.contentLabel.text = self.name
            contentView = iconView
        case .newMessage:
            contentView = ChatDirectionLabelView()
            
        }
        self.view.addSubview(self.contentView!)
        self.view.backgroundColor = .clear
        contentView?.edges(to: self.view)        
    }
    
    func setupData() {
        
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let self = self else { return }
            
            if let context = context as? ChatDirectionContext {
                self.context = context
            }
            
        }).disposed(by: disposeBag)
        
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let self = self else { return }
            
            self.endLoading()
            
            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))
                
            case .loading(let reason):
                if reason == .initialRefresh {
                    self.startLoading()
                }
                
            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))
                
            case .loadMore(_):
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))
                
            case .noMore:
                //                self.stopInfiniteScrolling(self.tableView, haveNoMore: true)
                break
                
            case .noData:
                //                self.view.showNoData(<#title#>, icon: <#imageName#>)
                break
                
            case .normal(_):
                //                self.view.hiddenNoData()
                //
                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break
                
            case .error(_, _):
                //                self.showToastBox(false, message: error.localizedDescription)
                
                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break
            }
        }).disposed(by: disposeBag)
    }
}

//MARK: - TableViewDelegate

//extension ChatDirectionViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.<#cell#>.name, for: indexPath) as! <#cell#>
//
//        return cell
//    }
//}


//MARK: - View Event

extension ChatDirectionViewController {
    @objc func chatDirectionLabelViewDidClicked(_ data:[String: Any]) {
       self.delegate?.clicked(self)
    }
    
    @objc func chatDirectionIconViewDidClicked(_ data:[String: Any]) {
        self.delegate?.clicked(self)
    }
}

