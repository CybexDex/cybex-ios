//
//  ExchangeViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class ExchangeViewController: BaseViewController {
    var coordinator: (ExchangeCoordinatorProtocol & ExchangeStateManagerProtocol)?
    var type: ExchangeType = .buy
    var lastPrice: Decimal = 0
    
    var pair: Pair? {
        didSet {
            self.children.forEach { (viewController) in
                if var viewController = viewController as? TradePair {
                    viewController.pariInfo = pair!
                }
            }
        }
    }

    @IBOutlet weak var containerView: ExchangeView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.coordinator?.setupChildVC(self)
    }

    override func configureObserveState() {

    }
}

extension ExchangeViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }

    func refresh() {
        self.children.forEach { (viewController) in
            if let vc = viewController as? TradePair {
                vc.refresh()
            }
        }
    }

    func resetView() {
        self.children.forEach { (viewController) in
            if let vc = viewController as? TradePair {
                vc.resetView()
            }
        }
    }

    func appear() {
        self.children.forEach { (viewController) in
            if let vc = viewController as? TradePair {
                vc.appear()
            }
        }
    }

    func disappear() {
        self.children.forEach { (viewController) in
            if let vc = viewController as? TradePair {
                vc.disappear()
            }
        }
    }
}

extension ExchangeViewController {
    @objc func orderbookClicked(_ data: [String: Any]) {
        if let price = data["price"] as? String {
            self.coordinator?.switchPriceToBusinessVC(price, isBuy: self.type == .buy)
        }
    }
}
