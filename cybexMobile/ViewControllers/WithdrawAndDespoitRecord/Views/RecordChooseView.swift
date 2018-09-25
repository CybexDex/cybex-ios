//
//  RecordChooseView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum RecordChooseViewType: Int {
    case name = 0
    case type
}

@IBDesignable
class RecordChooseView: CybexBaseView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    
    
    @IBInspectable var name: String = "" {
        didSet {
            nameLabel.locali = name
        }
    }
    
    @IBInspectable var content: String = "" {
        didSet {
            contentLabel.locali = content
        }
    }
    
    @IBInspectable var subtype: Int = 0 {
        didSet {
            
        }
    }
    
    
    enum Event:String {
        case RecordChooseViewDidClicked
        case RecordContainerViewDidClicked
        case presentChooseVC
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
    }
    
    func setupSubViewEvent() {
        self.containerView.rx.tapGesture().when(UIGestureRecognizerState.recognized).asObservable().subscribe(onNext: { [weak self](tap) in
            guard let `self` = self else { return }
            self.sendEventWith(Event.RecordContainerViewDidClicked.rawValue, userinfo: ["index": self.subtype])
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.RecordChooseViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension RecordChooseView {
    @objc func RecordContainerViewDidClicked(_ data: [String: Any]) {
        let vc = UIViewController()
        vc.view.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        vc.preferredContentSize = CGSize(width: self.containerView.width, height: 165)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = self.containerView
        vc.popoverPresentationController?.sourceRect = self.containerView.bounds
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        self.next?.sendEventWith(Event.presentChooseVC.rawValue , userinfo: ["data": vc])
    }
}

extension RecordChooseView: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
