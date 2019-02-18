//
//  DeployTicketView.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/9.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import TangramKit
import SwiftTheme

class DeployTicketView: UIView {
    static let RowKey: [[String]] = [["account"], ["asset", "amount"]]
    static let RowInfo: [[[String]]] = [
        [
            [R.string.localizable.ticket_check_account.key.localized(),
             R.string.localizable.ticket_check_account_placeholder.key.localized()]
        ],
        [
            [R.string.localizable.ticket_deploy_asset.key.localized(),
             R.string.localizable.ticket_deploy_asset_placeholder.key.localized()],
            [R.string.localizable.ticket_depoly_amount.key.localized(),
             R.string.localizable.ticket_depoly_amount_placeholder.key.localized()]
        ]
    ]

    lazy var accountView: TitleTextfieldView = {
        let accountView = TitleTextfieldView()
        return accountView
    }()

    lazy var assetView: TitleTextfieldView = {
        let assetView = TitleTextfieldView()
        return assetView
    }()

    lazy var amountView: TitleTextfieldView = {
        let amountView = TitleTextfieldView()
        return amountView
    }()

    lazy var textFieldViews: [[TitleTextfieldView]] = {
       return [[accountView], [assetView, amountView]]
    }()

    var contentView: GrowContentView!

    lazy var feeAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        label.text = "0.01 CYB"
        label.sizeToFit()
        label.textAlignment = .right

        return label
    }()

    lazy var depolyButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = 4
        button.backgroundColor = .steel
        button.setBackgroundImage(R.image.btn_color_orange(), for: .normal)
        button.locali = R.string.localizable.ticket_use_title.key
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        return button
    }()

    enum Event: String {
        case scan
        case chooseAsset
        case deploy
    }

    var buttonIsEnable: Bool = false {
        didSet {
            depolyButton.setBackgroundImage(
                buttonIsEnable ?
                R.image.btnColorOrange() :
                R.image.btnColorGrey(),
                for: .normal)
            depolyButton.isUserInteractionEnabled = buttonIsEnable
            depolyButton.alpha = buttonIsEnable ? 1.0 : 0.5
        }
    }

    func setupUI() {
        contentView = GrowContentView(frame: self.frame)
        contentView.datasource = self

        addSubview(contentView)

        initTitleTextFieldView()

        contentView.updateContentSize()

        self.performSelector(onMainThread: #selector(self.setupBottomView), with: nil, waitUntilDone: false)
    }

    @objc func setupBottomView() {
        let feeLayout = TGRelativeLayout()
        feeLayout.tg_top ~= contentView.bottom
        feeLayout.tg_width ~= self.width
        feeLayout.tg_height ~= .wrap
        feeLayout.tg_padding = UIEdgeInsets(top: 12,
                                            left: 25,
                                            bottom: 0,
                                            right: 25)
        addSubview(feeLayout)

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .steel
        label.text = R.string.localizable.transfer_fee.key.localized()
        label.textAlignment = .left
        label.sizeToFit()
        feeLayout.addSubview(label)

        feeAmountLabel.tg_right ~= 0
        feeLayout.addSubview(feeAmountLabel)

        depolyButton.height = 48
        depolyButton.bottom = self.bottom - 48
        depolyButton.width = self.width - 26
        depolyButton.left = 13
        depolyButton.addTarget(self, action: #selector(buttonDidClicked(_:)), for: .touchUpInside)
        addSubview(depolyButton)
    }

    @objc func buttonDidClicked(_ button: UIButton) {
        self.next?.sendEventWith(Event.deploy.rawValue,
                                 userinfo: [:])
    }

    func initTitleTextFieldView() {
        for (section, secV) in textFieldViews.enumerated() {
            for (row, v)  in secV.enumerated() {
                v.tag = section * 100 + row
                v.delegate = self
                v.datasource = self
                v.updateContentSize()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DeployTicketView: GrowContentViewDataSource {
    func numberOfSection(_ contentView: GrowContentView) -> NSInteger {
        return 2
    }

    func numberOfRowWithSection(_ contentView: GrowContentView, section: NSInteger) -> NSInteger {
        return section == 0 ? 1 : 2
    }

    func marginOfContentView(_ contentView: GrowContentView) -> CGFloat {
        return UIHelper.Page.margin.rawValue
    }

    func heightWithSectionHeader(_ contentView: GrowContentView, section: NSInteger) -> CGFloat {
        return section == 1 ? 12 : 0
    }

    func cornerRadiusOfSection(_ contentView: GrowContentView, section: NSInteger) -> CGFloat {
        return 4
    }

    func shadowSettingOfSection(_ contentView: GrowContentView, section: NSInteger) -> GrowContentViewShadowModel {
        return GrowContentViewShadowModel(
            color: ThemeManager.currentThemeIndex == 0 ? UIColor.black10 : UIColor.steel20,
            offset: CGSize(width: 0, height: 4),
            radius: 4,
            opacity: 0.2)
    }

    func viewOfIndexpath(_ contentView: GrowContentView, indexpath: NSIndexPath) -> (view: UIView, key: String) {
        return (view: textFieldViews[indexpath.section][indexpath.row],
                key: DeployTicketView.RowKey[indexpath.section][indexpath.row])
    }
}

extension DeployTicketView: TitleTextFieldViewDelegate, TitleTextFieldViewDataSource {
    func textIntroduction(titleTextFieldView: TitleTextfieldView) {

    }
    
    func textActionTrigger(titleTextFieldView: TitleTextfieldView, selected: Bool, index: NSInteger) {
        if titleTextFieldView == accountView {
            self.next?.sendEventWith(Event.scan.rawValue,
                                     userinfo: [:])
        } else if titleTextFieldView == assetView {
            self.next?.sendEventWith(Event.chooseAsset.rawValue,
                                     userinfo: [:])
        }
    }
    
    func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String {
        if titleTextFieldView == amountView {
            return R.string.localizable.ticket_asset_left.key.localizedFormat("-")
        }
        return ""
    }
    
    func textUISetting(titleTextFieldView: TitleTextfieldView) -> TitleTextSetting {
        let section = titleTextFieldView.tag / 100
        let row = titleTextFieldView.tag % 100

        return TitleTextSetting(title: DeployTicketView.RowInfo[section][row][0],
                                placeholder: DeployTicketView.RowInfo[section][row][1],
                                warningText: "",
                                introduce: "",
                                isShowPromptWhenEditing: false,
                                showLine: true,
                                isSecureTextEntry: false)
    }
    
    func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting] {
        if titleTextFieldView == accountView {
            return [TextButtonSetting(imageName: R.image.ic_scan.name,
                                      selectedImageName: R.image.ic_scan.name,
                                      isShowWhenEditing: false)]
        } else if titleTextFieldView == assetView {
            return [TextButtonSetting(imageName: R.image.ic_down_24_px.name,
                                      selectedImageName: R.image.ic_down_24_px.name,
                                      isShowWhenEditing: false)]
        }

        return []
    }
}
