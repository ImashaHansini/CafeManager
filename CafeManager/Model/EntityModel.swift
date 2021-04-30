//
//  EntityModel.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import Foundation

struct User{
    var userName: String
    var userEmail: String
    var userPassword: String
    var userPhone: String
    
}
struct FoodItem{
    var _id: String
    var foodName: String
    var foodDescription: String
    var foodPrice: Double
    var discount: Int
    var image: String
    var category: String
    var isActive: Bool
}

struct Order {
    var orderID: String = ""
    var orderStatus: String = ""
    var orderTotal: Double = 0
}

struct Category {
    var categoryID: String
    var categoryName: String
    }

