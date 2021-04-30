//
//  CategoryCollectionViewCell.swift
//  CafeManager
//
//  Created by Imasha on 4/30/21.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCategoryName: UILabel!
    
    class var reuseIdentifier: String {
        return "CategoryCollectionCellReusable"
    }
    
    class var nibName: String {
        return "CategoryCollectionViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configXIB(category: Category) {
        lblCategoryName.text = category.categoryName
        }
}
