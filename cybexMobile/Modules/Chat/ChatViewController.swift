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

import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController {
    let sectionInset = UIEdgeInsets(top: 12, left: 13, bottom: 12, right: 13)
    
    var downInputView: ChatDownInputView?
    
    open override var inputAccessoryView: UIView? {
        return nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        setupData()
        setupEvent()
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

        self.coordinator?.disconnect()
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self, let downInputView = self.downInputView, let userinfo = notification.userInfo as NSDictionary?, let nsValue = userinfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else { return }
            let keyboardRec = nsValue.cgRectValue
            var rectOfView = self.view.frame
            rectOfView.origin.y -= keyboardRec.size.height
            self.view.frame = rectOfView
            
            if let shadowView = self.shadowView {
                shadowView.isHidden = false
            }
            else {
                self.setupShadowView()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self, let upInputView = self.upInputView, let downInputView = self.downInputView else { return }
            upInputView.isHidden = true
            self.shadowView?.isHidden = true
            var rectOfView = self.view.frame
            rectOfView.origin.y = 0
            self.view.frame = rectOfView
            downInputView.height(56)
            guard let text = upInputView.textView.text, text.isEmpty == false else {
                return
            }
            downInputView.inputTextField.text = text
        }
    }
    
    func loadFirstMessages() {
        self.coordinator?.connectChat("BTC/ETH")
        DispatchQueue.global(qos: .userInitiated).async {
            SampleData.shared.getAdvancedMessages(count: 10) { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
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
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func setupUI() {
        
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
        messagesCollectionView.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.white.hexString(true)]
        
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
        self.downInputView?.height(56)
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("")
        }
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? TextMessageCell else {
            return UICollectionViewCell()
        }
        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case let .attributedText(attr) = message!.kind, let range = attr.string.range(of: "sasd_ss: ") {
            let frame = cell.messageLabel.nameRect(range.nsRange)
            
            var focusView: UIView!
            if let lastView = cell.messageContainerView.viewWithTag(2018) {
                focusView = lastView
            } else {
                focusView = UIView()
                focusView.tag = 2018
                cell.addSubview(focusView)
                focusView.rx.tapGesture().skip(1).asObservable().subscribe(onNext: { (_) in
                    print(11111)
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
        self.coordinator?.state.messages.asObservable().subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }

        }).disposed(by: disposeBag)
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
        self.coordinator?.send("xxx", username: "", sign: "")
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
        
        for component in inputBar.inputTextView.components {
            
            if let str = component as? String {
                let message = ChatCommonMessage(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = ChatCommonMessage(image: img, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
            
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
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
        upInputView.textView.text = ""
        upInputView.isHidden = false
        upInputView.textView.becomeFirstResponder()
    }
    
    @objc func sendMessage(_ data: [String: Any]) {
//        self.coordinator?.openNewMessageVC(self.downInputView!)
        // create new message
        
        let messageView = ChatDirectionIconView()
        self.view.addSubview(messageView)
        messageView.contentLabel.textColor = UIColor.pastelOrange
        messageView.contentLabel.text = R.string.localizable.chat_new_message(100)
        messageView.icon.theme1ImageName = R.image.watchlist_new_message.name
        messageView.icon.theme2ImageName = R.image.watchlist_new_message_white.name
        
        messageView.bottomToTop(of: self.downInputView!)
        messageView.centerX(to: self.downInputView!)
    }
    
    @objc func chatDirectionIconViewDidClicked(_ data: [String: Any]) {
        guard let messageView = data["self"] as? ChatDirectionIconView else { return }
        messageView.removeFromSuperview()
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
