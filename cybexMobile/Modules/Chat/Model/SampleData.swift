/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import CoreLocation
import ChatRoom

final internal class SampleData {

    static let shared = SampleData()

    private init() {}
    
    enum MessageTypes: UInt32, CaseIterable {
        case Text = 0
        case AttributedText = 1
        case Photo = 2
        case Video = 3
        case Emoji = 4
        case Location = 5
        case Url = 6
        case Phone = 7
        case Custom = 8
        
        static func random() -> MessageTypes {
            // Update as new enumerations are added
            let maxValue = Custom.rawValue
            
            let rand = arc4random_uniform(maxValue+1)
            return MessageTypes(rawValue: 1)!
        }
    }

    let system = Sender(id: "000000", displayName: "System")
    let nathan = Sender(id: "000001", displayName: "Nathan Tannar")
    let steven = Sender(id: "000002", displayName: "Steven Deutsch")
    let wu = Sender(id: "000003", displayName: "Wu Zhong")

    lazy var senders = [nathan, steven, wu]

    var currentSender: Sender {
        return system
    }

    var now = Date()
    
    let messageImages: [UIImage] = [R.image.img_etologo()!, R.image.img_etologo()!]

    let emojis = [
        "👍",
        "😂😂😂",
        "👋👋👋",
        "😱😱😱",
        "😃😃😃",
        "❤️"
    ]
    
    let attributes = ["Font1", "Font2", "Font3", "Font4", "Color", "Combo"]
    
    let locations: [CLLocation] = [
        CLLocation(latitude: 37.3118, longitude: -122.0312),
        CLLocation(latitude: 33.6318, longitude: -100.0386),
        CLLocation(latitude: 29.3358, longitude: -108.8311),
        CLLocation(latitude: 39.3218, longitude: -127.4312),
        CLLocation(latitude: 35.3218, longitude: -127.4314),
        CLLocation(latitude: 39.3218, longitude: -113.3317)
    ]
    
    func attributedString(with text: String) -> NSAttributedString {
        let nsString = NSString(string: text)
        var mutableAttributedString = NSMutableAttributedString(string: text)
        let randomAttribute = 0
        let range = NSRange(location: 0, length: nsString.length)
        let paragraph = NSMutableParagraphStyle()
        let font = UIFont.systemFont(ofSize: 14)
        paragraph.firstLineHeadIndent = 8
        paragraph.maximumLineHeight = 22
        paragraph.minimumLineHeight = 22

        switch attributes[randomAttribute] {
        case "Font1":
            mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            mutableAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: range)
            mutableAttributedString.addAttribute(NSAttributedString.Key.baselineOffset, value:labelBaselineOffset(22, fontHeight: font.lineHeight), range: range)
            mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white80, range: range)

        case "Font2":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)], range: range)
        case "Font3":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], range: range)
        case "Font4":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: range)
        case "Color":
            mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: range)
        case "Combo":
            let msg9String = "十月一号之前就是这样，来回震荡，出不来趋势的。不过相信接下来的一个星期会有趋势出来的，破6800还是6300。应该很快出来结果，这个价位拖的时间太长了，多空都耗不起。"
            let msg9Text = NSString(string: msg9String)
            let msg9AttributedText = NSMutableAttributedString(string: String(msg9Text))
            
            msg9AttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: msg9Text.length))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)], range: msg9Text.range(of: ".attributedText()"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], range: msg9Text.range(of: "bold"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: msg9Text.range(of: "italic"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: msg9Text.range(of: "colored"))
            mutableAttributedString = msg9AttributedText
        default:
            fatalError("Unrecognized attribute for mock message")
        }
        
        return NSAttributedString(attributedString: mutableAttributedString)
    }

    func dateAddingRandomTime() -> Date {
        let randomNumber = Int(arc4random_uniform(UInt32(10)))
        if randomNumber % 2 == 0 {
            let date = Calendar.current.date(byAdding: .hour, value: randomNumber, to: now)!
            now = date
            return date
        } else {
            let randomMinute = Int(arc4random_uniform(UInt32(59)))
            let date = Calendar.current.date(byAdding: .minute, value: randomMinute, to: now)!
            now = date
            return date
        }
    }
    
    func randomMessageType() -> MessageTypes {
        let messageType = MessageTypes.random()

        return messageType
    }

    func randomMessage(allowedSenders: [Sender]) -> ChatMessage {

        let randomNumberSender = Int(arc4random_uniform(UInt32(allowedSenders.count)))
        
        let uniqueID = NSUUID().uuidString
        let sender = allowedSenders[randomNumberSender]
        let date = dateAddingRandomTime()

        switch randomMessageType() {
        case .Text:
            let randomSentence = "十月一号之前就是这样，来回震荡，出不来趋势的。不过相信接下来的一个星期会有趋势出来的，破6800还是6300。应该很快出来结果，这个价位拖的时间太长了，多空都耗不起。"
            return ChatMessage(text: randomSentence, sender: sender, messageId: uniqueID, date: date)
        case .AttributedText:
            let randomSentence = "sasd_ss:    十月一号之前就是这样😀😀，来回震荡，出不来趋势的。不过相信接下来的一个星期会有趋势出来的，破6800还是6300。应该很快出来结果，这个价位拖的时间太长了，多空都耗不起。"
            let attributedText = attributedString(with: randomSentence)
            return ChatMessage(attributedText: attributedText, sender: senders[randomNumberSender], messageId: uniqueID, date: date)
        case .Photo:
            let randomNumberImage = Int(arc4random_uniform(UInt32(messageImages.count)))
            let image = messageImages[randomNumberImage]
            return ChatMessage(image: image, sender: sender, messageId: uniqueID, date: date)
        case .Video:
            let randomNumberImage = Int(arc4random_uniform(UInt32(messageImages.count)))
            let image = messageImages[randomNumberImage]
            return ChatMessage(thumbnail: image, sender: sender, messageId: uniqueID, date: date)
        case .Emoji:
            let randomNumberEmoji = Int(arc4random_uniform(UInt32(emojis.count)))
            return ChatMessage(emoji: emojis[randomNumberEmoji], sender: sender, messageId: uniqueID, date: date)
        case .Location:
            let randomNumberLocation = Int(arc4random_uniform(UInt32(locations.count)))
            return ChatMessage(location: locations[randomNumberLocation], sender: sender, messageId: uniqueID, date: date)
        case .Url:
            return ChatMessage(text: "https://github.com/MessageKit", sender: sender, messageId: uniqueID, date: date)
        case .Phone:
            return ChatMessage(text: "123-456-7890", sender: sender, messageId: uniqueID, date: date)
        case .Custom:
            return ChatMessage(custom: "                十月一号之前就是这样，来回震荡，出不来趋势的。不过相信接下来的一个星期会有趋势出来的，破6800还是6300。应该很快出来结果，这个价位拖的时间太长了，多空都耗不起。", sender: system, messageId: uniqueID, date: date)
        }
    }

    func getMessages(count: Int, completion: ([ChatMessage]) -> Void) {
        var messages: [ChatMessage] = []
        // Disable Custom Messages
        UserDefaults.standard.set(false, forKey: "Custom Messages")
        for _ in 0..<count {
            let message = randomMessage(allowedSenders: senders)
            messages.append(message)
        }
        completion(messages)
    }
    
    func getAdvancedMessages(count: Int, completion: ([ChatMessage]) -> Void) {
        var messages: [ChatMessage] = []
        // Enable Custom Messages
        UserDefaults.standard.set(true, forKey: "Custom Messages")
        for _ in 0..<count {
            let message = randomMessage(allowedSenders: senders)
            messages.append(message)
        }
        completion(messages)
    }
    
    func getMessages(count: Int, allowedSenders: [Sender], completion: ([ChatMessage]) -> Void) {
        var messages: [ChatMessage] = []
        // Disable Custom Messages
        UserDefaults.standard.set(false, forKey: "Custom Messages")
        for _ in 0..<count {
            let message = randomMessage(allowedSenders: allowedSenders)
            messages.append(message)
        }
        completion(messages)
    }

    func getAvatarFor(sender: Sender) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").first
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        switch sender {
        case nathan:
            return Avatar(image: R.image.img_etologo()!, initials: initials)
        case steven:
            return Avatar(image: R.image.img_etologo()!, initials: initials)
        case wu:
            return Avatar(image: R.image.img_etologo()!, initials: initials)
        case system:
            return Avatar(image: nil, initials: "SS")
        default:
            return Avatar(image: nil, initials: initials)
        }
    }

}
