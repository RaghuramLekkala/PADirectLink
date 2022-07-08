//
//  MessageCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 16/06/22.
//

import UIKit
import MessageKit

class MessageCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    static let identifier = "MessageCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "MessageCell", bundle: nil)
    }
    var senderId: String = ""
    
    @IBOutlet weak var senderMessageBuble: UIView!
    @IBOutlet weak var receiverMessageBuble: UIView!
    @IBOutlet weak var senderMessageLabel: UITextView!
    @IBOutlet weak var receiverMessageLabel: UITextView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var receiverLabel: UILabel!
    
    var attachments = [Attachments]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        senderMessageLabel.isUserInteractionEnabled = true
        senderMessageLabel.isEditable = false
        senderMessageLabel.isSelectable = true
        
        receiverMessageBuble.layer.cornerRadius = contentView.frame.width * 0.06
        senderMessageBuble.layer.cornerRadius = contentView.frame.width * 0.06
        
        if let uuidValue = UserDefaults.standard.string(forKey: "UUID"){
            senderId = uuidValue
        }
        senderMessageLabel.delegate = self
    }
    
    
    func configure(with viewModel: Message) {
        switch viewModel.kind {
        case .text(let value):
            if viewModel.sender.senderId != senderId {
                let url = senderMessageLabel.checkForUrls(text: value)
                if (url.count != 0) {
                    let url = url[0]
                    let replaced = value.replacingOccurrences(of: "http", with: "https")
                    senderMessageLabel.addHyperLinksToText(originalText:replaced, hyperLink: url.absoluteString, urlString: url)
                }else{
                    senderMessageLabel.text = value
                }
                break
            }
            else{
                receiverMessageLabel?.text = value
                break
            }
        default:
            break
        }
        
    }
}

extension UITextView {
    func checkForUrls(text: String) -> [URL] {
        let types: NSTextCheckingResult.CheckingType = .link
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            return matches.compactMap({$0.url})
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        return []
    }
    
    func addHyperLinksToText(originalText: String, hyperLink: String, urlString: URL) {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: fullRange)
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        self.attributedText = attributedOriginalText
    }
}

extension MessageCell: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("URL is: ", URL)
        return false
    }
}
