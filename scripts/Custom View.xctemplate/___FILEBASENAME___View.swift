//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

@IBDesignable
class ___VARIABLE_productName:identifier___View: BaseView {
    enum Event:String {
        case ___VARIABLE_productName:identifier___ViewDidClicked
    }
    
    override var data: Any? {
        didSet {
            
        }
    }
    
    override func setup() {
        super.setup()
        
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.___VARIABLE_productName:identifier___ViewDidClicked.rawValue, userinfo: [:])
    }
}
