//
//  WithdrawAndDespoitRecordViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class WithdrawAndDespoitRecordViewController: BaseViewController {

    var coordinator: (WithdrawAndDespoitRecordCoordinatorProtocol & WithdrawAndDespoitRecordStateManagerProtocol)?
    @IBOutlet weak var headerView: RecordHeaderView!

    var selectedIndex: RecordChooseType = RecordChooseType.Asset
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.endLoading()
    }

    override func refreshViewController() {

    }

    func setupUI() {
        self.localizedText = R.string.localizable.record_all.key.localizedContainer()
    }

    func setupData() {

    }

    func setupEvent() {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.coordinator?.setupChildrenVC(segue)
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
//                    self.startLoading()
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

            case .error(let error, _):
                self.showToastBox(false, message: error.localizedDescription)

                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: - View Event

extension WithdrawAndDespoitRecordViewController {
    @objc func presentChooseVC(_ data: [String: Any]) {
        if let vc = data["data"] as? RecordChooseViewController {
            self.present(vc, animated: true) {
                vc.view.superview?.cornerRadius = 2
                vc.view.cornerRadius = 2

            }
        }
    }

    @objc func RecordContainerViewDidClicked(_ data: [String: Any]) {
        guard let index = data["index"] as? Int, let chooseView = data["self"] as? RecordChooseView else { return }
        let vc = R.storyboard.comprehensive.recordChooseViewController()!
        vc.preferredContentSize = CGSize(width: chooseView.containerView.width, height: index == 1 ? 165 : 122)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = chooseView.containerView
        vc.popoverPresentationController?.sourceRect = chooseView.containerView.bounds
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        vc.typeIndex = index == 1 ? .Asset : .FoudType
        self.selectedIndex = vc.typeIndex
        vc.delegate = self
        vc.coordinator = RecordChooseCoordinator(rootVC: self.navigationController as! BaseNavigationController)
        self.present(vc, animated: true) {
            self.view.superview?.cornerRadius = 2
        }
    }
}
extension WithdrawAndDespoitRecordViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        if self.selectedIndex == .Asset {
            self.headerView.assetInfoView.contentLabel.textColor = UIColor.steel
            self.headerView.assetInfoView.stateImage.image = R.image.ic2()
        } else {
            self.headerView.typeInfoView.contentLabel.textColor = UIColor.steel
            self.headerView.typeInfoView.stateImage.image = R.image.ic2()
        }
        return true
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension WithdrawAndDespoitRecordViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String) {

        switch sender.typeIndex {
        case .Asset:
            self.headerView.assetInfoView.contentLabel.text = info.filterJade
            self.headerView.assetInfoView.contentLabel.textColor = UIColor.steel
            self.headerView.assetInfoView.stateImage.image = R.image.ic2()
            self.coordinator?.childrenFetchData(info, index: RecordChooseType.Asset)
            break
        case .FoudType:
            self.headerView.typeInfoView.contentLabel.text = info.filterJade
            self.headerView.typeInfoView.contentLabel.textColor = UIColor.steel
            self.headerView.typeInfoView.stateImage.image = R.image.ic2()
            self.coordinator?.childrenFetchData(info, index: RecordChooseType.FoudType)
            break
        }
        sender.dismiss(animated: true, completion: nil)
    }
}
