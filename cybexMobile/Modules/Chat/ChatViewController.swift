//
//  ChatViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import ChatRoom
import MapKit
import cybex_ios_core_cpp
import TinyConstraints
import BeareadToast_swift


import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController {
    let sectionInset = UIEdgeInsets(top: 12, left: 13, bottom: 12, right: 13)
    weak var toast: BeareadToast?

    var downInputView: ChatDownInputView?
    var messageView: ChatDirectionIconView?
    open override var inputAccessoryView: UIView? {
        return nil
    }
    var pair: Pair?
    var isRealName: Bool = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var downInputViewHeightConstraint: Constraint?
    var iconView: ChatDirectionIconView?
    var shadowView: UIView?
    var upInputView: ChatUpInputView?
    var coordinator: (ChatCoordinatorProtocol & ChatStateManagerProtocol)?
    private(set) var context: ChatContext?
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var messageList: [ChatCommonMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enableAutoToolbar = false
        setupUI()
        self.startLoading()
        setupData()
        setupEvent()
    }
    
    
    func startLoading() {
        guard let hud = toast else {
            toast = BeareadToast.showLoading(inView: self.view)
            return
        }
        
        if !hud.isDescendant(of: self.view) {
            toast = BeareadToast.showLoading(inView: self.view)
        }
    }
    
    override func leftAction(_ sender: UIButton) {
        self.coordinator?.disconnect()
        super.leftAction(sender)
    }
    
    
    
    func isLoading() -> Bool {
        return self.toast?.alpha == 1
    }
    
    func endLoading() {
        toast?.hide(true)
    }
    
    func setupShadowView() {
        self.shadowView = UIView(frame: self.view.bounds)
        self.shadowView?.theme_backgroundColor = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).hexString(true) ,UIColor.steel50.hexString(true)]
        self.view.insertSubview(self.shadowView!, belowSubview: self.downInputView!)
        self.shadowView!.rx.tapGesture().asObservable().when(GestureRecognizerState.recognized).subscribe(onNext: { [weak self](tap) in
            guard let `self` = self, let upInputView = self.upInputView  else {
                return
            }
            upInputView.textView.resignFirstResponder()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let lastMessage = self.messageList.last, let pair = self.pair else {
            return
        }
        if var dic = UserDefaults.standard.value(forKey: "lastReadIds") as? [Pair: String] {
            dic[pair] = lastMessage.messageId
            UserDefaults.standard.set(dic, forKey: "lastReadIds")
        }
    }
    
    deinit {
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadFirstMessages() {
        self.coordinator?.connectChat(self.title ?? "")
    }
    
    func insertMessage(_ message: ChatCommonMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            if self.isLastSectionVisible() == true {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    
    func scrollToBottomAnimationAction() {
        if self.messagesCollectionView.contentOffset.y < 10 {
            return
        }
        
        let contentSizeHeight = self.messagesCollectionView.contentSize.height
        let boundsHeight = self.messagesCollectionView.bounds.height
        let inSetBottom = self.messagesCollectionView.contentInset.bottom
        let offSetY = self.messagesCollectionView.contentOffset.y
        
        if abs(contentSizeHeight - boundsHeight + inSetBottom - offSetY) < 1 {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        else {
            setupNewMessageTipView()
        }
    }
    
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func setupUI() {
        if let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] {
            self.title = quoteInfo.symbol.filterJade + "/" + baseInfo.symbol.filterJade
        }
        
        self.view.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.paleGrey.hexString(true)]
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .never
        }
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messageInputBar.delegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
       
        messagesCollectionView.theme_backgroundColor = [UIColor.darkTwo.hexString(true), UIColor.white.hexString(true)]
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = sectionInset
        
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageIncomingMessagePadding(.zero)
        layout?.attributedTextMessageSizeCalculator.incomingMessageLabelInsets = .zero
        
        // 约束重写
        self.messagesCollectionView.top(to: self.view)
        self.messagesCollectionView.left(to: self.view)
        self.messagesCollectionView.right(to: self.view)
        
        self.downInputView = ChatDownInputView()
        self.view.addSubview(self.downInputView!)
        self.downInputView?.topToBottom(of: self.messagesCollectionView)
        
        self.downInputView?.bottomToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
        
        self.downInputView?.left(to: self.view)
        self.downInputView?.right(to: self.view)
        self.downInputViewHeightConstraint = self.downInputView?.height(56)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("")
        }
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? TextMessageCell else {
            return UICollectionViewCell()
        }

        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        
        var userName = message!.sender.displayName
        if userName.count > 15 {
            userName = userName.substring(from: 0, length: 15)! + "..."
        }
        if case let .attributedText(attr) = message!.kind, let range = attr.string.range(of: userName + ":") {
            let frame = cell.messageLabel.nameRect(range.nsRange)
            var focusView: UIView!
            if let lastView = cell.messageContainerView.viewWithTag(2018) {
                focusView = lastView
            } else {
                focusView = UIView()
                focusView.tag = 2018
                cell.addSubview(focusView)
                focusView.rx.tapGesture().when(GestureRecognizerState.recognized).asObservable().subscribe(onNext: { [weak self](ges) in
                    guard let `self` = self else { return }
                   
                    if let icView = self.iconView, let _ = icView.superview {
                        icView.removeFromSuperview()
                    }
                    else {
                        if message!.sender.displayName.count < 15 {
                            return
                        }
                        let rect = self.view.convert(focusView.frame, from: cell)
                        self.iconView = ChatDirectionIconView()
                        self.view.addSubview(self.iconView!)
                        self.iconView?.left(to: self.view, offset: rect.origin.x)
                        self.iconView?.right(to: self.view, offset: -rect.origin.x)
                        self.iconView?.bottom(to: self.view, offset: (rect.origin.y - self.view.height))
                        self.iconView?.contentLabel.text = message!.sender.displayName
                    }
                }).disposed(by: cell.disposeBag)
            }
            focusView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height )
            focusView.backgroundColor = UIColor.clear
        }
        return cell
    }

    func setupData() {
        loadFirstMessages()
    }

    func setupEvent() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self, let userinfo = notification.userInfo as NSDictionary?, let nsValue = userinfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else { return }
            guard let upInputView = self.upInputView, upInputView.textView.isFirstResponder else { return }
            
            if let shadowView = self.shadowView {
                shadowView.isHidden = false
            }
            else {
                self.setupShadowView()
            }
            self.downInputViewHeightConstraint?.constant = 138
            self.view.setNeedsLayout()
            self.messagesCollectionView.scrollToBottom(animated: true)
            let keyboardRec = nsValue.cgRectValue
            var rectOfView = self.view.frame
            rectOfView.origin.y = -keyboardRec.size.height
            self.view.frame = rectOfView
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self, let upInputView = self.upInputView, let downInputView = self.downInputView else { return }
            upInputView.isHidden = true
            self.shadowView?.isHidden = true
            var rectOfView = self.view.frame
            rectOfView.origin.y = 0
            self.view.frame = rectOfView
            self.downInputViewHeightConstraint?.constant = 56
            self.view.setNeedsLayout()
            guard let text = upInputView.textView.text, text.isEmpty == false, text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false else {
                downInputView.setupBtnState()
                return
            }
            downInputView.inputTextField.text = text
            downInputView.setupBtnState()
        }

        self.coordinator?.state.messages.asObservable().skip(1).subscribe(onNext: {[weak self] (messages) in
            guard let self = self else { return }
            self.endLoading()

            if messages.count > 1 {
                self.messageList = messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
            else if messages.count == 1  {
                self.insertMessage(messages.first!)
                self.scrollToBottomAnimationAction()
            }
        }).disposed(by: disposeBag)
        
        
        self.coordinator?.state.numberOfMember.asObservable().skip(1).subscribe(onNext: { [weak self](numberOfMember) in
            guard let `self` = self else { return }
            
            if let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] {
                self.title = quoteInfo.symbol.filterJade + "/" + baseInfo.symbol.filterJade + "(\(numberOfMember))"
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.chatState.asObservable().skip(1).subscribe(onNext: { [weak self](connectState) in
            guard let `self` = self, let connectState = connectState else { return }
           
            var message = ""
            switch connectState{
            case .chatServiceDidClosed:
                message = "链接关闭"
            case .chatServiceDidFail:
                message = "链接失败"
            case .chatServiceDidDisConnected:
                message = "断开链接"
            case .chatServiceDidConnected:
                message = "已链接"
            }
            if message != "已链接" {
                BeareadToast.showError(text: message, inView: self.view, hide: 1)
            }
            else {
                BeareadToast.showSucceed(text: message, inView: self.view, hide: 1)
            }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("login_success"), object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            if let downInputView = self.downInputView {
                downInputView.sendBtn.setTitle(R.string.localizable.chat_input_send.key.localized(), for: UIControl.State.normal)
            }
            if let upInputView = self.upInputView {
                upInputView.sendBtn.setTitle(R.string.localizable.chat_input_send.key.localized(), for: UIControl.State.normal)
            }
        }
    }
    
    
    func setupNewMessageTipView() {
        if let msgView = self.messageView {
            if msgView.isHidden == false {
                msgView.notReadCount += 1
            }
            else {
                msgView.isHidden = false
                msgView.notReadCount = 1
            }
            msgView.contentLabel.text = R.string.localizable.chat_new_message.key.localizedFormat(msgView.notReadCount)
        }
        else {
            self.messageView = ChatDirectionIconView()
            self.view.addSubview(messageView!)
            messageView?.contentLabel.textColor = UIColor.pastelOrange
            messageView?.notReadCount += 1
            messageView?.contentLabel.text = R.string.localizable.chat_new_message.key.localizedFormat(messageView!.notReadCount)
            messageView?.icon.theme1ImageName = R.image.watchlist_new_message.name
            messageView?.icon.theme2ImageName = R.image.watchlist_new_message_white.name
            
            messageView?.bottomToTop(of: self.downInputView!)
            messageView?.centerX(to: self.downInputView!)
        }
    }
}


extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return SampleData.shared.currentSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
}

// MARK: - MSGDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        //        self.coordinator?.send("xxx", username: "", sign: "")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
}

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor.clear
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .none
    }
    
    func messageFooterView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let view = messagesCollectionView.dequeueReusableFooterView(MessageReusableView.self, for: indexPath)
        var frame = view.frame
        frame.origin.x = sectionInset.left
        frame.size.width = messagesCollectionView.bounds.width - sectionInset.left - sectionInset.right
        
        view.frame = frame
        view.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        
        return view
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: messagesCollectionView.bounds.width - sectionInset.left - sectionInset.right, height: 1)
    }
}


extension ChatViewController {
    @objc func callKeyboard(_ data: [String: Any]) {
        guard let upInputView = self.upInputView else {
            self.upInputView = ChatUpInputView()
            self.downInputView?.addSubview(self.upInputView!)
            self.upInputView?.bottom(to: self.downInputView!)
            self.upInputView?.rightToSuperview()
            self.upInputView?.leftToSuperview()
            self.upInputView?.height(138)
            self.upInputView?.textView.becomeFirstResponder()
            return
        }
        upInputView.textView.text = self.downInputView?.inputTextField.text
        upInputView.numberOfTextLabel.text = "\(upInputView.textView.text.count)/100"
        upInputView.setupBtnState()
        upInputView.isHidden = false
        upInputView.textView.becomeFirstResponder()
        
        self.messageView?.isHidden = true
        self.messageView?.notReadCount = 0
    }
    
    @objc func sendRealName(_ data: [String: Any]) {
        if let isRealName = data["isRealName"] as? Bool {
            self.isRealName = isRealName
        }
    }
    
    @objc func sendMessageEvent(_ data: [String: Any]) {
        guard let message = data["message"] as? String else {
            return
        }
        let trimedString = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard trimedString.count != 0 else {
            self.showToastBox(false, message: R.string.localizable.chat_space_message.key.localized())
            return
        }
        if let upInputView = self.upInputView {
            upInputView.textView.text = ""
            upInputView.numberOfTextLabel.text = "0/100"
            upInputView.numberOfTextLabel.textColor = UIColor.steel
            upInputView.setupBtnState()
        }
        
        self.downInputView?.inputTextField.text = ""
        self.downInputView?.setupBtnState()
        if self.isRealName {
            if !UserManager.shared.isLocked {
                self.coordinator?.send(message,
                                       username: UserManager.shared.name.value!,
                                       sign: self.isRealName ? BitShareCoordinator.signMessage(UserManager.shared.name.value!, message: message)!.replacingOccurrences(of: "\"", with: "") : "")
            }
            else {
                self.downInputView?.inputTextField.text = message
                self.downInputView?.setupBtnState()
                self.showPasswordBox()
            }
        }
        else {
            self.coordinator?.send(message,
                                   username: UserManager.shared.name.value!,
                                   sign: "")
        }
    }
    
    @objc func chatDirectionIconViewDidClicked(_ data: [String: Any]) {
        guard let messageView = data["self"] as? ChatDirectionIconView else { return }
        messageView.isHidden = true
        messageView.notReadCount = 0
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension ChatViewController: ChatDirectionViewControllerDelegate {
    @objc func clicked(_ sender: ChatDirectionViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        return false
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension ChatViewController {
    override func passwordDetecting() {
        
    }
    
    override func passwordPassed(_ passed: Bool) {
        if passed {
            guard let message = self.downInputView?.inputTextField.text else {
                return
            }
            self.coordinator?.send(message,
                                   username: UserManager.shared.name.value!,
                                   sign: self.isRealName ? BitShareCoordinator.signMessage(UserManager.shared.name.value!, message: message)!.replacingOccurrences(of: "\"", with: "") : "")
            self.downInputView?.inputTextField.text = ""
            self.downInputView?.setupBtnState()
        }
        else {
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }
}


extension ChatViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.iconView?.removeFromSuperview()
    }
}
