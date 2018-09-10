//
//  String+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension String {
    func tagText(_ tag: String) -> String {
        return "<\(tag)>" + self + "</\(tag)>"
    }
}
