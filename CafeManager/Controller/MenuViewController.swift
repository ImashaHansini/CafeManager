//
//  MenuViewController.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import UIKit
import Firebase
import FirebaseStorage
import NotificationBannerSwift
import ProgressHUD

class MenuViewController: UIViewController {

    @IBOutlet weak var txtFoodName: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtDiscount: UITextField!
    @IBOutlet weak var imgFood: UIImageView!
    
    let databaseReference = Database.database().reference()
       
       var categoryPicker = UIPickerView()
       var selectedCategoryIndex = 0
       var categoryList: [Category] = []
       
       var selectedImage: UIImage?
       var imagePicker: ImagePicker!
       
       override func viewDidLoad() {
            super.viewDidLoad()
            self.imagePicker = ImagePicker(presentationController: self, delegate: self)
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onPickImageClicked))
            self.imgFood.isUserInteractionEnabled = true
            self.imgFood.addGestureRecognizer(gesture)
            ProgressHUD.animationType = .multipleCircleScaleRipple
            ProgressHUD.colorAnimation = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.refreshCategories()
       }
    
    @IBAction func onAddFoodPressed(_ sender: UIButton) {
        let foodItem = FoodItem(
                    _id: "",
                    foodName: txtFoodName.text ?? "",
                    foodDescription: txtDescription.text ?? "",
                    foodPrice: Double(txtPrice.text ?? "") ?? 0,
                    discount: Int(txtDiscount.text ?? "") ?? 0,
                    image: "",
                    category: categoryList[selectedCategoryIndex].categoryName,
                    isActive: true)
                
                self.addFoodItem(foodItem: foodItem)
        }
        
        @objc func onPickImageClicked(_ sender: UIImageView) {
            self.imagePicker.present(from: sender)
        }
    }

        extension MenuViewController {
            
            func addFoodItem(foodItem: FoodItem) {
                ProgressHUD.show("Please Wait!")
                guard let image = self.selectedImage else {
                    let banner = NotificationBanner(title: "Error Saving Data", subtitle: "Please add an Image", style: .danger)
                    banner.show()
                    return
                }
                
                if let uploadData = image.jpegData(compressionQuality: 0.5) {
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    Storage.storage().reference().child("foodItemImages").child(foodItem.foodName).putData(uploadData, metadata: metaData) {
                        meta, error in
                        ProgressHUD.dismiss()
                        if let error = error {
                            print(error.localizedDescription)
                            let banner = NotificationBanner(title: "Error Uploading Image", subtitle: error.localizedDescription, style: .danger)
                            banner.show()
                            return
                        }
                        
                        Storage.storage().reference().child("foodItemImages").child(foodItem.foodName).downloadURL(completion: {
                            (url,error) in
                            guard let downloadURL = url else {
                                if let error = error {
                                    print(error.localizedDescription)
                                    let banner = NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger)
                                    banner.show()
                                }
                                return
                            }
                            
                            let banner = NotificationBanner(title: "Done", subtitle: "Image uploaded successfully", style: .success)
                            banner.show()
                            
                            let data = [
                                "food_name" : foodItem.foodName,
                                "description" : foodItem.foodDescription,
                                "price" : foodItem.foodPrice,
                                "discount" : foodItem.discount,
                                "category" : foodItem.category,
                                "isActive" : foodItem.isActive,
                                "imgage" : downloadURL.absoluteString
                            ] as [String : Any]
                            
                            self.databaseReference
                                .child("foodItems")
                                .childByAutoId()
                                .setValue(data) {
                                    error, ref in
                                    if let error = error {
                                        let banner = NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger)
                                        banner.show()
                                    } else {
                                        let banner = NotificationBanner(title: "Done", subtitle: "Food item added successfully", style: .success)
                                        banner.show()
                                    }
                                }
                            
                        })
                    }
                }
                
            }
            
            func refreshCategories() {
                self.categoryList.removeAll()
                databaseReference
                    .child("categories")
                    .observeSingleEvent(of: .value, with: {
                        snapshot in
                        if snapshot.hasChildren() {
                            guard let data = snapshot.value as? [String: Any] else {
                                return
                            }
                            
                            for category in data {
                                if let categoryInfo = category.value as? [String: String] {
                                    self.categoryList.append(Category(categoryID: category.key, categoryName: categoryInfo["name"]!))
                                }
                            }
                            self.setupCategoryPicker()
                        }
                    })
            }
        }

        extension MenuViewController: UIPickerViewDelegate, UIPickerViewDataSource {
            func setupCategoryPicker() {
                let pickerToolBar = UIToolbar()
                pickerToolBar.sizeToFit()
                
        //        let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onValuePicked))
                let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onPickerCancelled))
                let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                pickerToolBar.setItems([space, cancelButton], animated: true)
                
                txtCategory.inputAccessoryView = pickerToolBar
                txtCategory.inputView = categoryPicker
                categoryPicker.delegate = self
                categoryPicker.dataSource = self
            }
            
            @objc func onPickerCancelled() {
                self.view.endEditing(true)
            }
            
            func numberOfComponents(in pickerView: UIPickerView) -> Int {
                return 1
            }
            
            func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                return categoryList.count
            }
            
            func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                return categoryList[row].categoryName
            }
            
            func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                txtCategory.text = categoryList[row].categoryName
                selectedCategoryIndex = row
            }
        }

        extension MenuViewController: ImagePickerDelegate {
            func didSelect(image: UIImage?) {
                self.imgFood.image = image
                self.selectedImage = image
            }
        }
