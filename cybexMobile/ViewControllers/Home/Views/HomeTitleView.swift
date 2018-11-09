//
//  HomeTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class HomeTitleView: UIView {

    @IBOutlet weak var nameBtn: UIButton!
    @IBOutlet weak var volBtn: UIButton!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var appliesBtn: UIButton!
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var volL: UILabel!
    @IBOutlet weak var priceL: UILabel!
    @IBOutlet weak var appliesL: UILabel!
    
    
    enum Event: String {
        case sortedByName
        case sortedByVol
        case sortedByPrice
        case sortedByApplies
    }
    
    @IBAction func sorted(_ sender: UIButton) {
        let tag = sender.tag
        clearBtnState(sender)
        sender.tag = tag + 1
        switch sender.tag % 3 {
        case 0:
            sender.setImage(R.image.ic_filtrate_nor(), for: .normal)
            break
        case 1:
            sender.setImage(R.image.ic_filtrate_up(), for: .normal)
            break
        case 2:
            sender.setImage(R.image.ic_filtrate_down(), for: .normal)
            break
        default:
            break
        }
        switch sender {
        case self.nameBtn:
            self.next?.sendEventWith(Event.sortedByName.rawValue, userinfo: ["data": sender.tag % 3])
        case self.volBtn:
            self.next?.sendEventWith(Event.sortedByVol.rawValue, userinfo: ["data": sender.tag % 3])
        case self.priceBtn:
            self.next?.sendEventWith(Event.sortedByPrice.rawValue, userinfo: ["data": sender.tag % 3])
        case self.appliesBtn:
            self.next?.sendEventWith(Event.sortedByApplies.rawValue, userinfo: ["data": sender.tag % 3])
        default:
            break
        }
    }
    
   
    
    func clearBtnState(_ sender: UIButton) {
        volBtn.tag = 0
        nameBtn.tag = 0
        priceBtn.tag = 0
        appliesBtn.tag = 0
        volBtn.setImage(R.image.ic_filtrate_nor(), for: .normal)
        nameBtn.setImage(R.image.ic_filtrate_nor(), for: .normal)
        priceBtn.setImage(R.image.ic_filtrate_nor(), for: .normal)
        appliesBtn.setImage(R.image.ic_filtrate_nor(), for: .normal)
    }
    
    func setup() {
        setUpSubviewsEvent()
    }
    
    func setUpSubviewsEvent() {
       nameL.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe { [weak self](tap) in
            guard let `self` = self else { return }
            self.sorted(self.nameBtn)
        }.disposed(by: disposeBag)
        volL.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe { [weak self](tap) in
            guard let `self` = self else { return }
            self.sorted(self.volBtn)
        }.disposed(by: disposeBag)
        priceL.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe { [weak self](tap) in
            guard let `self` = self else { return }
            self.sorted(self.priceBtn)
        }.disposed(by: disposeBag)
        appliesL.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe { [weak self](tap) in
            guard let `self` = self else { return }
            self.sorted(self.appliesBtn)
        }.disposed(by: disposeBag)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
