//
//  MyCellTableViewCell.swift
//  IOSChatBot
//
//  Created by Raghuram on 21/06/22.
//

import UIKit

class MyCellTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var viewModelData: [Attachments] = []
    
    
    static let identifier = "MyCellTableViewCell"
    
    var width: CGFloat?
    var height: CGFloat?
    
    static func nib() -> UINib{
        return UINib(nibName: "MyCellTableViewCell", bundle: nil)
    }

    @IBOutlet weak var myCellCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        width = contentView.frame.size.width
        super.awakeFromNib()
        myCellCollectionView.register(MyCell.nib(), forCellWithReuseIdentifier: MyCell.identifier)
        myCellCollectionView.register(TextCollectionViewCell.nib(), forCellWithReuseIdentifier: TextCollectionViewCell.identifier)
        contentView.addSubview(myCellCollectionView)
        myCellCollectionView.dataSource = self
        myCellCollectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - layout
    override func layoutSubviews() {
        super.layoutSubviews()
        myCellCollectionView.frame = contentView.bounds
    }
    
    func configure(with model: [Attachments]) {
        viewModelData = model
        myCellCollectionView.reloadData()
    }
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModelData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        width = contentView.frame.width
        if (viewModelData[indexPath.section].content?.images != nil) {
            height =  width!/1.5
            guard let cellA = myCellCollectionView.dequeueReusableCell(withReuseIdentifier: MyCell.identifier, for: indexPath) as? MyCell else {
                 fatalError()
             }
             cellA.configure(with: viewModelData[indexPath.row])
             return cellA
        }else{
            height = width!/2
            guard let cellB = myCellCollectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.identifier, for: indexPath) as? TextCollectionViewCell else {
                fatalError()
            }
            cellB.configure(with: viewModelData[indexPath.section])
            return cellB
        }  
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let height = height{
            return CGSize(width: contentView.frame.width - 20, height: height)
        }
        return CGSize(width: contentView.frame.width - 20, height:contentView.frame.width/1.5 )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
