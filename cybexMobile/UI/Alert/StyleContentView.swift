//
//  StyleContentView.swift
//  Demo
//
//  Created by DKM on 2018/6/8.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import SwiftRichString
import TinyConstraints

class StyleContentView: UIView ,Views{
    var content : Any?{
        get {
            return self.data
        }
        set{
            if let contents = newValue as? [NSAttributedString]{
                self.data = contents
            }
        }
    }
    

    var data : [NSAttributedString]? {
        didSet{
            setupUI()
            updateHeight()
        }
    }
    
    func setupUI(){
        if let data = data{
            for view in self.subviews{
                view.removeFromSuperview()
            }            
            var testLabel : StyleLabel!
            
            for i in 0...data.count-1{
                let lable = StyleLabel(frame: CGRect.zero)
                addSubview(lable)
                
                if testLabel == nil{
                    lable.top(to: self)
                    lable.leading(to: self)
                    lable.trailing(to: self)
                }else{
                    lable.topToBottom(of: testLabel)
                    lable.leading(to: self)
                    lable.trailing(to: self)
                    if data.count - 1 == i{
                        lable.bottom(to: self,offset:-18)
                    }
                }
                testLabel = lable
                lable.data = data[i]
            }
        }
    }
    
    func updateHeight(){
        guard let _ = self.subviews.last else {
            return
        }
        var height : CGFloat = 0.0
        for view in self.subviews{
            height = height + view.height
        }
        self.height = height
        invalidateIntrinsicContentSize()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

