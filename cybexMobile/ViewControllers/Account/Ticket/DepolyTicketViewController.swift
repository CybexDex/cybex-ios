//
//  DepolyTicketViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/9.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import TangramKit

class DepolyTicketViewController: BaseViewController {

    override func loadView() {
        self.title = R.string.localizable.ticket_title.key.localized()
        
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]

        let tableLayout = TGTableLayout(.vert)
        tableLayout.tg_hspace = 2
        tableLayout.tg_vspace = 2
        tableLayout.tg_margin(TGLayoutPos.tg_safeAreaMargin)   //和父视图的安全区域保持一致的尺寸，因为这里和父视图四周的边距都是安全区边距。你可以设置为0看看效果。
        self.view.addSubview(tableLayout)
    }

    override func viewDidLoad() {

    }
}
