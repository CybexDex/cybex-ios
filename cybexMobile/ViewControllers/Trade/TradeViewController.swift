//
//  TradeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints
import Localize_Swift
import SwiftTheme
import SwiftyUserDefaults

protocol TradePair {
    var pariInfo: Pair {get set}
    
    func refresh() //每隔时间段刷新

    func resetView()

    func appear()

    func disappear()
}

extension TradePair {
    func refresh() {
    }

    func resetView() {
        
    }

    func appear() {

    }

    func disappear() {
        
    }
}

class TradeViewController: BaseViewController {
    var tradeTitltView: TradeNavTitleView! // CYB/ETH 切换交易对
    var chooseTitleView: UIView? //mask

    @IBOutlet weak var topBanner: UIImageView!
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView! //container
    var titlesView: CybexTitleView? //segment

    @IBOutlet weak var scrollView: UIScrollView!

    var isShowingTitleView = false
    
    var selectedIndex: Int = 0 {
        didSet {
            moveToPage()
        }
    }

    var currentTopViewController: TradePair? {
        for vc in children {
            if let vc = vc as? ExchangeViewController, vc.type.rawValue == selectedIndex {
                return vc
            } else if let vc = vc as? OpenedOrdersViewController, selectedIndex == 2 {
                return vc
            }
        }

        return nil
    }
    
    var coordinator: (TradeCoordinatorProtocol & TradeStateManagerProtocol)?
    private(set) var context: TradeContext?

    var pair: Pair = Pair(base: AssetConfiguration.CybexAsset.ETH.id, quote: AssetConfiguration.CybexAsset.CYB.id) {
        didSet {
            self.children.forEach { (viewController) in
                if var viewController = viewController as? TradePair {
                    viewController.resetView()
                    viewController.pariInfo = pair
                    viewController.appear()
                }
            }
        }
    }
    

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()

        self.startLoading()
        setupData()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        currentTopViewController?.appear()

        let noticeShow = !Defaults.hasKey(.showContestTip) || Defaults[.showContestTip]
        if let context = self.context, context.pageType == .game, noticeShow {
            self.coordinator?.showNoticeVC()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        currentTopViewController?.disappear()
    }

    func setupData() {
        switch AppEnv.current {
        case .product:
            self.pair = Pair(base: AssetConfiguration.CybexAsset.ETH.id, quote: AssetConfiguration.CybexAsset.CYB.id)
        case .test:
            self.pair = Pair(base: AssetConfiguration.CybexAsset.ETH.id, quote: AssetConfiguration.CybexAsset.EOS.id)
        case .uat:
            self.pair = Pair(base: AssetConfiguration.CybexAsset.ETH.id, quote: AssetConfiguration.CybexAsset.EOS.id)
        }

        self.children.forEach { (viewController) in
            if var viewController = viewController as? TradePair {
                viewController.pariInfo = pair
            }
        }
    }
    
    func setupUI() {
        setupNavi()
        titlesView = CybexTitleView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 32))
        topView.addSubview(self.titlesView!)
        self.titlesView!.data = [R.string.localizable.trade_buy.key,
                                 R.string.localizable.trade_sell.key,
                                 R.string.localizable.trade_open_orders.key]
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let self = self else { return }

            self.titlesView!.data = [R.string.localizable.trade_buy.key,
                                     R.string.localizable.trade_sell.key,
                                     R.string.localizable.trade_open_orders.key]
            self.titlesView!.selectedIndex = self.selectedIndex
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    func setupNavi() {
        configLeftNavigationButton(R.image.icCandle())
        configRightNavButton(R.image.ic_star_border_24_px())
        
        tradeTitltView = TradeNavTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
        tradeTitltView.delegate = self
        self.navigationItem.titleView = tradeTitltView
    }

    func moveToPage() {
        switch selectedIndex {
        case 0:
            moveToTradeView(isBuy: true)
        case 1:
            moveToTradeView(isBuy: false)
        case 2:
            moveToMyOpenedOrders()
        default:
            break
        }
    }
    
    @objc override func rightAction(_ sender: UIButton) {
        self.coordinator?.openMyHistory()
    }
    
    @objc override func leftAction(_ sender: UIButton) {
        self.coordinator?.openMarket(pair)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.coordinator?.setupChildVC(segue)
    }
    
    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let self = self else { return }

            if let context = context as? TradeContext {
                self.context = context

                if context.pageType == .normal {
                    self.bannerHeightConstraint.constant = 0
                } else {
                    self.bannerHeightConstraint.constant = 40
                    self.topBanner.image = UIImage.themeAndLocalizedImage()

                    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification),
                                                           object: nil,
                                                           queue: nil,
                                                           using: {_ in
                                                            self.topBanner.image = UIImage.themeAndLocalizedImage()
                    })
                    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                                           object: nil,
                                                           queue: nil,
                                                           using: {_ in
                                                            self.topBanner.image = UIImage.themeAndLocalizedImage()
                    })

                }

            }

        }).disposed(by: disposeBag)

        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: { (_) in
                if appData.tickerData.value.count == 0 {
                    return
                }
                
                self.refreshView()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func refreshView() {
        self.tradeTitltView.title.text = pair.quote.symbol.filterSystemPrefix + "/" + pair.base.symbol.filterSystemPrefix
        self.children.forEach { (viewController) in
            if let viewController = viewController as? TradePair {
                viewController.refresh()
            }
        }
    }
    
    func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * scrollView.bounds.width
    }
    
    func moveToMyOpenedOrders() {
        if let viewController = children[2] as? TradePair {
            viewController.refresh()
        }
        self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: 2), y: 0), animated: false)
    }
    
    func moveToTradeView(isBuy: Bool) {
        let index = isBuy ? 0 : 1
        if let viewController = children[index] as? TradePair {
            viewController.refresh()
        }
        self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: false)
    }
}

extension TradeViewController: TradeNavTitleViewDelegate {
    @discardableResult func sendEventActionWith() -> Bool {
        if appData.tickerData.value.count == 0, !self.isShowingTitleView {
            return false
        }
        self.isShowingTitleView = true

        if self.chooseTitleView != nil {
            self.chooseTitleView?.removeFromSuperview()
            self.chooseTitleView = nil
            self.coordinator?.removeHomeVC { [weak self] in
                self?.isShowingTitleView = false
                guard let self = self else { return }
                self.tradeTitltView.title.text = self.pair.quote.symbol.filterSystemPrefix + "/" + self.pair.base.symbol.filterSystemPrefix
            }
        } else {
            self.chooseTitleView = UIView()
            self.chooseTitleView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(self.chooseTitleView!)

            var marginBottom: CGFloat = 0
            if #available(iOS 11.0, *) {
                marginBottom = self.view.safeAreaInsets.bottom
            }

            self.chooseTitleView?.edges(to: self.view, insets: UIEdgeInsets(top: 0, left: 0, bottom: -marginBottom, right: 0), priority: .required, isActive: true)
            self.view.layoutIfNeeded()
            self.coordinator?.addHomeVC { [weak self] in
                self?.isShowingTitleView = false
            }
        }
        return true
    }
}

extension TradeViewController {
    @objc func sendBtnAction(_ data: [String: Any]) {
        if let seleIndex = data["selectedIndex"] as? Int {
            selectedIndex = seleIndex

            for vc in children {
                if let vc = vc as? TradePair {
                    vc.disappear()
                }
            }
            currentTopViewController?.appear()
        }
    }
}
