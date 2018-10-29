//
//  TitleTextfieldView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import TinyConstraints

typealias TextDidBegainEdit = (() -> Void)
typealias TextDidEndEdit = (() -> Void)
typealias TextDidChanged = (() -> Void)

protocol TitleTextFieldViewDelegate: NSObjectProtocol {
    func textIntroduction(titleTextFieldView: TitleTextfieldView)
    func textActionTrigger(titleTextFieldView: TitleTextfieldView, selected: Bool, index: NSInteger)
}

protocol TitleTextFieldViewDataSource: NSObjectProtocol {
    func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String
    func textUISetting(titleTextFieldView: TitleTextfieldView) -> TitleTextSetting
    func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting]
}

@IBDesignable
class TitleTextfieldView: UIView {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var introduceLabel: UILabel!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var gapView: UIView!

    @IBOutlet weak var actionsView: UIStackView!

    @IBOutlet weak var unitLabel: UILabel!

    fileprivate var activityIndicator: UIActivityIndicatorView?
    let textActionTag = 999

    weak var delegate: TitleTextFieldViewDelegate?

    weak var datasource: TitleTextFieldViewDataSource? {
        didSet {
            self.reloadData()
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

    var loadingBtn: TextRightButton?

    var loadingState: ImageState = .normal {
        didSet {
            switch self.loadingState {
            case .normal:
                self.loadingBtn?.isHidden = true
                break
            case .loading:
                self.loadingBtn?.isHidden = false
                self.loadingBtn?.setImage(nil, for: .normal)
                self.startAnimation()
                break
            case .fail:
                self.loadingBtn?.isHidden = false
                self.stop()
                self.loadingBtn?.setImage(R.image.ic_close_24_px(), for: .normal)
                break
            case .success:
                self.loadingBtn?.isHidden = false
                self.stop()
                self.loadingBtn?.setImage(R.image.check_complete(), for: .normal)
                break
            }
        }
    }
    func startAnimation() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.activityIndicator?.style = .white
        self.activityIndicator?.center = CGPoint(x: 12, y: self.actionsView.height * 0.5)
        self.loadingBtn?.addSubview(self.activityIndicator!)
        self.activityIndicator?.startAnimating()
    }

    func stop() {
        self.activityIndicator?.stopAnimating()
    }

    var setting: TitleTextSetting! {
        didSet {
            titleLabel.text = setting.title

            introduceLabel.text = setting.introduce
            introduceLabel.isUserInteractionEnabled = true
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(introduce))
            introduceLabel.addGestureRecognizer(tapGestureRecognizer)

            textField.attributedPlaceholder = NSMutableAttributedString.init(string: setting.placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.steel50])
            textField.isSecureTextEntry = setting.isSecureTextEntry
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

    func reloadData() {
        setting = datasource?.textUISetting(titleTextFieldView: self)
        buttonSettings = datasource?.textActionSettings(titleTextFieldView: self)
        unit = datasource?.textUnitStr(titleTextFieldView: self)
    }

    func setupRightView() {
        guard (buttonSettings != nil) else {
            return
        }
        if actionsView.arrangedSubviews.count > 0 {
            actionsView.removeSubviews()
        }
        for (index, value) in (buttonSettings?.enumerated())! {
            if value.imageName == "loading_state" {
                let btn = TextRightButton(frame: .zero)
                actionsView.addArrangedSubview(btn)
                btn.width(24)
                btn.height(24)
                self.loadingBtn = btn
                btn.isHidden = value.isShowWhenEditing
            } else {
                let image = UIImage(named: value.imageName)
                let btn = TextRightButton()
                btn.tag = index + textActionTag
                btn.setImage(image, for: .normal)
                btn.setImage(UIImage(named: value.selectedImageName), for: .selected)
                btn.addTarget(self, action: #selector(handleAction(sender:)), for: .touchUpInside)
                btn.isShowWhenEditing = value.isShowWhenEditing
                btn.width(image?.size.width ?? -5 + 5)
                actionsView.addArrangedSubview(btn)
                btn.isHidden = value.isShowWhenEditing
            }
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
        delegate?.textActionTrigger(titleTextFieldView: self, selected: sender.isSelected, index: sender.tag - textActionTag)
    }

    func clearText() {
        textField.text = ""
    }

    func showPromoptView() {

    }

    func setup() {
        updateHeight()
    }

    @objc func introduce() {
        delegate?.textIntroduction(titleTextFieldView: self)
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
