//
//  QuickReplyCollectionViewCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 21/06/22.
//

import UIKit

class QuickReplyCollectionViewCell: UICollectionViewCell {
    
    let apiManager = ApiManager()
    var cid = ""
    var uuidVal = ""
    var nameVal = ""
    var tokenVal = ""
    var senderName = ""
    var streamURLVal = ""
    
    
    weak var delegate: AlternativeViewControllerDelegate?
    
    let viewController = AlternativeViewController()
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        apiManager.post(endpoint:  "/conversations/\(ApiManager.cid)/activities", token: tokenVal, body: ["type": "message", "from": [
            "id": uuidVal,
            "name": senderName
        ], "text": sender.currentTitle! as String])
       
    }
    @IBOutlet weak var actionButton: UIButton!
    
    
    
    static let identifier = "QuickReplyCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "QuickReplyCollectionViewCell", bundle: nil)
    }
    
    
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
        
        if let streamURL = UserDefaults.standard.string(forKey: "streamUrl"){
            streamURLVal = streamURL
        }
        actionButton.layer.borderWidth=2
        actionButton.layer.cornerRadius=6
        actionButton.layer.borderColor = CGColor(red: 121.0/255.0, green: 40.0/255.0, blue: 140.0/255.0, alpha: 1.0)
        delegate?.receive(viewController)
    }
    
    func configure(with actionData: Actions) {
        actionButton.setTitle(actionData.title, for: .normal)
    }

}
