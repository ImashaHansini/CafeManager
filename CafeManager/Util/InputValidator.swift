//
//  InputValidator.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import Foundation

class InputValidator {
    
    static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let nameRegEx = "[A-Za-z ]{2,100}"
    static let mobileRegex = "^(07)(0|1|2|5|6|7|8)[\\d]{7}$"
    
    static func isValidEmail(email: String) -> Bool {
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidName(name: String) -> Bool {
        let compRegex = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return compRegex.evaluate(with: name)
    }
    
    static func isValidPassword(pass: String, minLength: Int, maxLength: Int) -> Bool {
        return pass.count >= minLength && pass.count <= maxLength
    }
    
    static func isValidMobileNo(_ mobileNo: String) -> Bool {
        let mobPred = NSPredicate(format:"SELF MATCHES %@", mobileRegex)
        return mobPred.evaluate(with: mobileNo)
    }
    
    
}
