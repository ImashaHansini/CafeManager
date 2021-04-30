//
//  FoodItemTableViewCell.swift
//  CafeManager
//
//  Created by Imasha on 4/30/21.
//

import UIKit
import Kingfisher

class FoodItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var switchFoodStatus: UISwitch!
    
    var delegate: FoodItemCellActions?
    var foodItem: FoodItem?
    
    var rowIndex = 0
    
    class var reuseIdentifier: String {
        return "FoodItemCellReusable"
    }
    
    class var nibName: String {
        return "FoodItemTableViewCell"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configXIB(foodItem: FoodItem, index: Int) {
        lblFoodName.text = foodItem.foodName
        lblDescription.text = foodItem.foodDescription
        imgFood.kf.setImage(with: URL(string: foodItem.image))
        lblDiscount.text = "\(foodItem.discount)%"
        
        switchFoodStatus.isOn = foodItem.isActive
        
        self.rowIndex = index
        self.foodItem = foodItem
    }
    
    @IBAction func onFoodStatusChanged(_ sender: UISwitch) {
       self.delegate?.onFoodItemStatusChanged(foodItem: self.foodItem!, status: sender.isOn)
            }
        }

        protocol FoodItemCellActions {
            func onFoodItemStatusChanged(foodItem: FoodItem, status: Bool)
        }
