//
//  AddAddressViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class AddAddressViewController: BaseViewController {

    
    @IBOutlet weak var containerView: AddAddressView!
    var coordinator: (AddAddressCoordinatorProtocol & AddAddressStateManagerProtocol)?

    var address_type : address_type!
    var addressVailed : Bool = false
    
	override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func commonObserveState() {
        coordinator?.subscribe(errorSubscriber) { sub in
            return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
        
        coordinator?.subscribe(loadingSubscriber) { sub in
            return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
        
        (self.containerView.address.content.rx.text.orEmpty <-> self.coordinator!.state.property.address).disposed(by: disposeBag)
        (self.containerView.mark.content.rx.text.orEmpty <-> self.coordinator!.state.property.note).disposed(by: disposeBag)
        (self.containerView.memo.content.rx.text.orEmpty <-> self.coordinator!.state.property.memo).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidEndEditing, object: self.containerView.mark.content, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            if let text = self.containerView.mark.content.text ,text.count != 0 {
                self.coordinator?.verityNote(true)
                if text.count > 15 {
                    self.containerView.mark.content.text = text.substring(from: 0, length: 15)
                }
            }else {
                self.coordinator?.verityNote(false)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidEndEditing, object: self.containerView.address.content, queue: nil) { [weak self](notification) in
            guard let `self` = self else {return}
            self.coordinator?.verityAddress(self.containerView.address.content.text, type: self.address_type)
        }
        
        Observable.combineLatest(self.coordinator!.state.property.addressVailed.asObservable(), self.coordinator!.state.property.noteVailed.asObservable()).subscribe(onNext: { [weak self](address_success,note_success) in
            guard let `self` = self else { return }
            guard address_success,note_success else {
                self.containerView.addBtn.isEnable = false
                return
            }
            self.containerView.addBtn.isEnable = true
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.containerView.addBtn.rx.tapGesture().when(.recognized).filter {[weak self] (tap) -> Bool in
            guard let `self` = self else { return false }
            
            return self.containerView.addBtn.canRepeat
            }.subscribe(onNext: { [weak self](tap) in
                guard let `self` = self else { return }
                let exit = AddressManager.shared.containAddressOfWithDraw(self.containerView.address.content.text)
                if exit.0 {
                    self.showToastBox(false, message: self.address_type == .withdraw ? R.string.localizable.address_exit.key.localized() : R.string.localizable.account_exit.key.localized())
                }
                else {
                    self.coordinator?.addAddress()
                }
                
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    override func configureObserveState() {
        commonObserveState()
        
    }
}
