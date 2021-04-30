//
//  SignInViewController.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import UIKit
import Firebase
import NotificationBannerSwift
import ProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ProgressHUD.animationType = .multipleCircleScaleRipple
        ProgressHUD.colorAnimation = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }

    @IBAction func onSignInPressed(_ sender: UIButton) {
        
       if !InputValidator.isValidEmail(email: txtEmail.text ?? "") {
            let banner = NotificationBanner(title: "Error Signing In", subtitle: "Please enter a valid Email address", style: .danger)
            banner.show()
            return
        }
        
       if !InputValidator.isValidPassword(pass: txtPassword.text ?? "", minLength: 6, maxLength: 50) {
            let banner = NotificationBanner(title: "Error Signing In", subtitle: "Please enter a valid Password", style: .danger)
            banner.show()
            return
        }
        
        authenticateUser(email: txtEmail.text!, password: txtPassword.text!)
    }
    func authenticateUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password:password){
            authResult, error in
            
            if let err = error {
                print(err.localizedDescription)
                //let rightView = UIImageView(image: #imageLiteral(resourceName: "Error"))
                let banner = NotificationBanner(title: "Error Signing In", subtitle: "Invalid Username or Password", style: .danger)
                banner.show()
                return
            }
            
            if let email = authResult?.user.email{
                self.getUserData(email: email)
            } else {
                let banner = NotificationBanner(title: "Error Signing In", subtitle: "User Email not found", style: .danger)
                banner.show()
            }
            
        }
    }
    
    func getUserData(email: String) {
        ProgressHUD.show("Loading!")
        ref.child("users")
        .child(email
        .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")).observe(.value,with: {
                (snapshot) in
                ProgressHUD.dismiss()
                if snapshot.hasChildren() {
                    if let data = snapshot.value {
                        if let userData = data as? [String: String] {
                            let user = User(
                                userName: userData["userName"]!,
                                userEmail: userData["userEmail"]!,
                                userPassword: userData["userPassword"]!,
                                userPhone: userData["userPhone"]!)
                            
                                let sessionMGR = SessionManager()
                                sessionMGR.saveUserLogin(user: user)
                                self.performSegue(withIdentifier: "SignInToHome", sender: nil)
                    }
                }
            } else {
                let banner = NotificationBanner(title: "Error Signing In", subtitle: "User not found", style: .danger)
                banner.show()
                }
        })
    }
}
