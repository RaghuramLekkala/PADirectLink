//
//  QuickReplyTableViewCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 21/06/22.
//

import UIKit

class QuickReplyTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AlternativeViewControllerDelegate?
    
    var actionData: [Actions] = []
    
    @IBOutlet weak var quickReplyCollectionView: UICollectionView!

    
    static let identifier = "QuickReplyTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "QuickReplyTableViewCell", bundle: nil)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        quickReplyCollectionView.register(QuickReplyCollectionViewCell.nib(), forCellWithReuseIdentifier: QuickReplyCollectionViewCell.identifier)
        
        quickReplyCollectionView.dataSource = self
        quickReplyCollectionView.delegate = self
        
        contentView.addSubview(quickReplyCollectionView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with action: [Actions]) {
        actionData = action
        quickReplyCollectionView.reloadData()
    }
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellB = quickReplyCollectionView.dequeueReusableCell(withReuseIdentifier: QuickReplyCollectionViewCell.identifier, for: indexPath) as? QuickReplyCollectionViewCell else {
            fatalError()
        }
        cellB.delegate = delegate
        cellB.actionButton.setTitle(actionData[indexPath.section].title, for: .normal)
        cellB.configure(with: actionData[indexPath.item])
        return cellB
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = contentView.frame.size.width/4
            return CGSize(width: width, height:30 )
    }
    
}
