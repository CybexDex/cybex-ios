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
        
    override func setup() {
        super.setup()
        
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.___VARIABLE_productName:identifier___ViewDidClicked.rawValue, userinfo: [:])
    }
}

extension ___VARIABLE_productName:identifier___View {
    func adapterModelTo___VARIABLE_productName:identifier___View(_ model:<#Type#>) {
        
    }
}