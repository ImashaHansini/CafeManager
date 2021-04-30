//
//  CategoryViewController.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import UIKit
import FirebaseDatabase
import NotificationBannerSwift
import ProgressHUD

class CategoryViewController: UIViewController {
    
    let databaseReference = Database.database().reference()
    
    var CategoryList: [Category] = []
    
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet weak var txtCategoryName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblCategory.register(UINib(nibName: CategoryInfoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: CategoryInfoTableViewCell.reuseIdentifier)
        ProgressHUD.animationType = .multipleCircleScaleRipple
        ProgressHUD.colorAnimation = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        refreshCategories()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onAddCategoryPressed(_ sender: UIButton) {
        if let name = txtCategoryName.text {
            addCategory(name: name)
        } else {
            let banner = NotificationBanner(title: "Error Saving Data", subtitle: "Enter a Category Name", style: .danger)
            banner.show()
        }
    }
}

extension CategoryViewController {
    func addCategory(name: String){
        ProgressHUD.show("Please Wait!")
        databaseReference
        .child("categories")
        .childByAutoId()
        .child("name")
        .setValue(name) {
            error, ref in
            ProgressHUD.dismiss()
            if let error = error {
                let banner = NotificationBanner(title: "Error Saving Data", subtitle: error.localizedDescription, style: .danger)
                banner.show()
            } else {
                let banner = NotificationBanner(title: "Category Added", subtitle: "Category created successfully", style: .success)
                banner.show()
                self.refreshCategories()
            }
        }
    }
    
    func refreshCategories() {
        ProgressHUD.show("Loading Categories!")
        self.CategoryList.removeAll()
        databaseReference
            .child("categories")
            .observeSingleEvent(of: .value, with: {
                    snapshot in
                    ProgressHUD.dismiss()
                    if snapshot.hasChildren() {
                        guard let data = snapshot.value as? [String: Any] else {
                            return
                        }
                        for category in data {
                            if let categoryInfo = category.value as? [String: String] {
                                self.CategoryList.append(Category(categoryID: category.key, categoryName: categoryInfo["name"]!))
                        }
                    }
                        self.tblCategory.reloadData()
                }
        })
    }
    
    func removeCategory(category: Category) {
        ProgressHUD.dismiss()
        databaseReference
        .child("categories")
            .child(category.categoryID)
            .removeValue() {
                error, databaseReference in
                ProgressHUD.dismiss()
                if error != nil{
                    let banner = NotificationBanner(title: "Error Deleting Data", subtitle: "Could not remove Category", style: .danger)
                    banner.show()
                } else {
                    let banner = NotificationBanner(title: "Category Removed", subtitle: "Category deleted successfully", style: .success)
                    banner.show()
                    self.refreshCategories()
                }
        }
    }
}
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CategoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblCategory.dequeueReusableCell(withIdentifier: CategoryInfoTableViewCell.reuseIdentifier, for: indexPath) as! CategoryInfoTableViewCell
            cell.selectionStyle = .none
        cell.configXIB(category: self.CategoryList[indexPath.row])
            return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeCategory(category: CategoryList[indexPath.row])
            refreshCategories()
    }
}
}
