//
//  MyCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 13/06/22.
//

import UIKit
import MessageKit


class MyCell: UICollectionViewCell {
    
    static let identifier = "MyCell"
    var uuidVal = ""
    var senderName = ""
    
    static func nib() -> UINib{
        return UINib(nibName: "MyCell", bundle: nil)
    }
    let apiManager = ApiManager()
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func buttonPressed(_ sender: Any) {
        apiManager.post(endpoint:  "/conversations/\(ApiManager.cid)/activities", token: ApiManager.tokenVal, body: ["type": "message", "from": [
            "id": uuidVal,
            "name": senderName
        ], "text": titleLabel.text! as String])
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.borderWidth = 0.5
        buttonPressedLabel.layer.borderWidth = 0.5
        descriptionLabel.textColor = .gray
        
        if let
            uuidValue = UserDefaults.standard.string(forKey: "UUID"){
            uuidVal = uuidValue
        }
        if let senderNameValue = UserDefaults.standard.string(forKey: "SENDERNAME"){
            senderName = senderNameValue
        }

    }
    @IBOutlet weak var buttonPressedLabel: UIButton!
    
    func configure(with viewModel: Attachments) {
        let url = URL(string: (viewModel.content?.images![0].url)!)
        DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async { [self] in
                        imageView?.image = UIImage(data: data!)
                    }
                }
        titleLabel?.text = viewModel.content?.title
        descriptionLabel.text = viewModel.content?.subtitle
        buttonPressedLabel.setTitle(viewModel.content?.title, for: .normal)
    }
}
