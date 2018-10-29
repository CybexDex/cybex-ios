//
//  TitleTextView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/4.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import TinyConstraints
import GrowingTextView

/*UI状态*/
enum TextUIStyle: Int {
    case common = 1
    case highlight = 2
    case warning = 3
}

/*Right Button Setting*/
class TextButtonSetting {
    var imageName = ""
    var selectedImageName = ""
    var isShowWhenEditing = false

    init(imageName: String, selectedImageName: String, isShowWhenEditing: Bool) {
        self.imageName = imageName
        self.selectedImageName = selectedImageName
        self.isShowWhenEditing = isShowWhenEditing
    }
}

/*Right Button*/
class TextRightButton: UIButton {
    var isShowWhenEditing = false
}

/*UI Setting*/
class TitleTextSetting {
    var title = ""
    var placeholder = ""
    var warningText = ""
    var introduce = ""
    var showLine = true
    var isShowPromptWhenEditing = true
    var isSecureTextEntry = false

    init(title: String, placeholder: String, warningText: String, introduce: String, isShowPromptWhenEditing: Bool, showLine: Bool, isSecureTextEntry: Bool) {
        self.title = title
        self.placeholder = placeholder
        self.introduce = introduce
        self.warningText = warningText
        self.showLine = showLine
        self.isShowPromptWhenEditing = isShowPromptWhenEditing
        self.isSecureTextEntry = isSecureTextEntry
    }
}

protocol TitleTextViewDelegate: NSObjectProtocol {
    func textIntroduction(titleTextView: TitleTextView)
    func textActionTrigger(titleTextView: TitleTextView, selected: Bool, index: NSInteger)
}

protocol TitleTextViewDataSource: NSObjectProtocol {
    func textUnitStr(titleTextView: TitleTextView) -> String
    func textUISetting(titleTextView: TitleTextView) -> TitleTextSetting
    func textActionSettings(titleTextView: TitleTextView) -> [TextButtonSetting]
}

@IBDesignable
class TitleTextView: UIView {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var introduceLabel: UILabel!

    @IBOutlet weak var textView: GrowingTextView!

    @IBOutlet weak var gapView: UIView!

    @IBOutlet weak var actionsView: UIStackView!

    @IBOutlet weak var unitLabel: UILabel!

    let textActionTag = 999

    weak var delegate: TitleTextViewDelegate?

    weak var datasource: TitleTextViewDataSource? {
        didSet {
            setting = datasource?.textUISetting(titleTextView: self)
            buttonSettings = datasource?.textActionSettings(titleTextView: self)
            unit = datasource?.textUnitStr(titleTextView: self)
        }
    }

    var buttonSettings: [TextButtonSetting]? {
        didSet {
            setupRightView()
        }
    }

    var unit: String? {
        didSet {
            unitLabel.text = unit
        }
    }

    var warningText: String? {
        didSet {
            setting.warningText = warningText ?? ""
        }
    }

    var setting: TitleTextSetting! {
        didSet {
            titleLabel.text = setting.title

            introduceLabel.text = setting.introduce
            introduceLabel.isUserInteractionEnabled = true
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(introduce))
            introduceLabel.addGestureRecognizer(tapGestureRecognizer)

            textView.attributedPlaceholder = NSMutableAttributedString.init(string: setting.placeholder,
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            textView.isSecureTextEntry = setting.isSecureTextEntry
            gapView.alpha = setting.showLine ? 1.0 : 0.0
        }
    }

    var checkStatus: TextUIStyle? {
        didSet {
            switch checkStatus! {
            case .highlight:
                highlightUI()
            case .warning:
                redSealUI()
            default:
                recoverUI()
                break
            }
        }
    }

    func setUnit(unit: String) {

    }

    func setupRightView() {
        guard (buttonSettings != nil) else {
            return
        }

        for (index, value) in (buttonSettings?.enumerated())! {
            let image = UIImage(named: value.imageName)
            let btn = TextRightButton()
            btn.tag = index + textActionTag
            btn.setImage(image, for: .normal)
            btn.setImage(UIImage(named: value.selectedImageName), for: .selected)
            btn.addTarget(self, action: #selector(handleAction(sender:)), for: .touchUpInside)
            btn.isShowWhenEditing = value.isShowWhenEditing
            btn.width((image?.size.width)! + 5)
            actionsView.addArrangedSubview(btn)
            btn.isHidden = value.isShowWhenEditing
        }
    }

    func reloadActionViews(isEditing: Bool) {
        for view in actionsView.arrangedSubviews {
            if let btn = view as? TextRightButton {
                btn.isHidden = btn.isShowWhenEditing && !isEditing
            }
        }
    }

    @objc func handleAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.textActionTrigger(titleTextView: self, selected: sender.isSelected, index: sender.tag - textActionTag)
    }

    func clearText() {
        textView.text = ""
    }

    func showPromoptView() {

    }

    func setup() {
        self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        updateHeight()
    }

    @objc func introduce() {
        delegate?.textIntroduction(titleTextView: self)
    }

    fileprivate func recoverUI() {
        //    titleLabel.text = setting.title
        //    titleLabel.textColor = UIColor.steel
        //    gapView.backgroundColor = UIColor.paleGreyTwo
    }

    fileprivate func redSealUI() {
        //    titleLabel.text = setting.warningText
        //    titleLabel.textColor = UIColor.scarlet
        //    gapView.backgroundColor = UIColor.scarlet
    }

    fileprivate func highlightUI() {
        //    titleLabel.text = setting.title
        //    titleLabel.textColor = UIColor.darkSlateBlue
        //    gapView.backgroundColor = UIColor.darkSlateBlue
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    func updateContentSize() {
        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
    }

    @objc func updateHeight() {
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
