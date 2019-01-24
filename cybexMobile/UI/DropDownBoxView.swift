//
//  DropDownBoxView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class DropDownBoxView: CybexBaseView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    enum Event:String {
        case dropDownBoxViewDidClicked
    }

    enum DropDownBoxKind: Int {
        case time = 0
        case kind
    }

    var dropKind: DropDownBoxKind = .time

    @IBInspectable
    var normalIcon: UIImage? {
        didSet{
            self.icon.image = normalIcon
        }
    }
    
    @IBInspectable
    var selectedIcon: UIImage? {
        didSet{
            self.icon.image = selectedIcon
        }
    }
    
    @IBInspectable
    var normalTextColor: UIColor? {
        didSet{
            self.nameLabel.textColor = normalTextColor
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor? {
        didSet{
            self.nameLabel.textColor = selectedTextColor
        }
    }
    
    func resetState() {
        self.icon.image = normalIcon
        self.nameLabel.textColor = normalTextColor
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        
        if let selectedColor = self.selectedTextColor {
            self.nameLabel.textColor = selectedColor
        }
        
        if let selectedImage = self.selectedIcon {
            self.icon.image = selectedImage
        }
        self.next?.sendEventWith(Event.dropDownBoxViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
