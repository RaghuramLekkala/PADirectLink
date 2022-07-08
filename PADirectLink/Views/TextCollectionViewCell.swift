//
//  TextCollectionViewCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 24/06/22.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TextCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "TextCollectionViewCell", bundle: nil)
    }
    
    
    let apiManager = ApiManager()
    var cid = ""
    var uuidVal = ""
    var nameVal = ""
    var tokenVal = ""
    var senderName = ""
    
    var url = ""
    
    let screenSize: CGRect = UIScreen.main.bounds


    @IBOutlet weak var textField: UITextView!
    @IBAction func buttonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func buttonTwoPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    @IBOutlet weak var buttonThreeOutlet: UIButton!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonTwoOutlet: UIButton!
    @IBAction func buttonThreePressed(_ sender: UIButton) {
        apiManager.post(endpoint:  "/conversations/\(ApiManager.cid)/activities", token: tokenVal, body: ["type": "message", "from": [
            "id": uuidVal,
            "name": senderName
        ], "text": sender.currentTitle! as String])
    }
    
    @IBOutlet weak var buttonTwoHeigh: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if let
            cidVal = UserDefaults.standard.string(forKey: "CID"){
            cid = cidVal
        }
        
        if let
            tokenValue = UserDefaults.standard.string(forKey: "token"){
            tokenVal = tokenValue
        }
        
        if let
            uuidValue = UserDefaults.standard.string(forKey: "UUID"){
            uuidVal = uuidValue
        }
        
        if let senderNameValue = UserDefaults.standard.string(forKey: "SENDERNAME"){
            senderName = senderNameValue
        }
        
        mainView.frame.size.width = screenSize.width - 32
        mainView.frame.size.height = 100
        mainView.layer.borderWidth = 1
        buttonOutlet.layer.borderWidth = 1
    }
    
    func addButton(item:Buttons, index: Int){
        
        if item.type == "openUrl" && index == 0 {
            if let urlVal = item.value{
                url = urlVal
            }
            buttonOutlet.setTitle(item.title, for: .normal)
        }
        
        if item.type == "openUrl" && index == 1 {
            if let urlVal = item.value{
                url = urlVal
            }
            buttonTwoOutlet.layer.borderWidth = 0.5
            buttonTwoOutlet.setTitle(item.title, for: .normal)
        }
        
        if item.type == "postBack" &&  index == 2 {
            buttonThreeOutlet.setTitle(item.title, for: .normal)
        }
        if item.type == "postBack" &&  index == 1 {
            buttonThreeOutlet.setTitle(item.title, for: .normal)
            buttonTwoOutlet.isHidden = true
            buttonTwoHeigh.constant = 0
            contentView.layoutIfNeeded()
        }
        
        
    }
    
    func configure(with data: Attachments) {
        textField.text = data.content?.text
        data.content?.buttons.map({item in
            for (index, itemVal)  in item.enumerated() {
                addButton(item: itemVal, index: index)
            }
        })
    }
}
