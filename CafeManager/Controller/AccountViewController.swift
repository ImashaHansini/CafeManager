//
//  AccountViewController.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import UIKit
import Firebase
import NotificationBannerSwift

class AccountViewController: UIViewController {

    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var tblOrders: UITableView!
    
   
        let datePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        
        var startDate: Date!
        var endDate: Date!
        
        let databaseReference = Database.database().reference()
        
        var orderList: [Order] = []
        var filteredOrders: [Order] = []
        
        var orderTotal: Double = 0
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tblOrders.register(UINib(nibName: AccountTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: AccountTableViewCell.reuseIdentifier)
            
    //        self.tblOrders.estimatedRowHeight = 250
    //        self.tblOrders.rowHeight = UITableView.automaticDimension
        }
        
        override func viewDidAppear(_ animated: Bool) {
            fetchOrders()
            buildDatePicker()
            txtFrom.text = dateFormatter.string(from: Date())
            txtTo.text = dateFormatter.string(from: Date())
        }

    }

    extension AccountViewController {
        func buildDatePicker() {
            
            startDate = Date()
            endDate = Date()
            
            let pickerToolBar = UIToolbar()
            pickerToolBar.sizeToFit()
            
            let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDatePicked))
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onPickerCancelled))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            pickerToolBar.setItems([doneAction, space, cancelButton], animated: true)
            txtFrom.inputAccessoryView = pickerToolBar
            txtTo.inputAccessoryView = pickerToolBar
            
            txtFrom.inputView = datePicker
            txtTo.inputView = datePicker
            datePicker.datePickerMode = .date
            dateFormatter.dateStyle = .medium
            
            if #available(iOS 13.4, *) {
               datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        @objc func onPickerCancelled() {
            self.view.endEditing(true)
        }
        
        @objc func onDatePicked() {
            if txtFrom.isFirstResponder {
                if datePicker.date > endDate {
                    txtTo.text = dateFormatter.string(from: datePicker.date)
                    endDate = datePicker.date
                    return
                }
                txtFrom.text = dateFormatter.string(from: datePicker.date)
                startDate = datePicker.date
            }
            if txtTo.isFirstResponder {
                if datePicker.date < startDate {
                    txtFrom.text = dateFormatter.string(from: datePicker.date)
                    startDate = datePicker.date
                    return
                }
                txtTo.text = dateFormatter.string(from: datePicker.date)
                endDate = datePicker.date
            }
            self.view.endEditing(true)
            filterOrders()
        }
    }

    extension AccountViewController {
        
        func getDateFromMills(dateInMills: Int64) -> Date {
            return Date(timeIntervalSince1970: (Double(dateInMills) / 1000.0))
        }
        
        func filterOrders() {
            filteredOrders.removeAll()
            let range = startDate...endDate
            for order in orderList {
                if range.contains(getDateFromMills(dateInMills: Int64(order.date))) {
                    filteredOrders.append(order)
                }
            }
            getOrderTotal()
            tblOrders.reloadData()
        }
        
        func getOrderTotal() {
            self.orderTotal = 0
            for order in filteredOrders {
                for item in order.orderItems {
                    self.orderTotal += item.price
                }
            }
            lblTotal.text = "\(orderTotal) LKR"
        }
        
        func fetchOrders() {
            self.filteredOrders.removeAll()
            self.orderList.removeAll()
            self.databaseReference
                .child("orders")
                .observeSingleEvent(of: .value, with: {
                    snapshot in
                    if snapshot.hasChildren() {
                        guard let data = snapshot.value as? [String: Any] else {
                            let banner = NotificationBanner(title: "Error", subtitle: "Could not send Data", style: .danger)
                            banner.show()
                            return
                        }
                        
                        for order in data {
                            if let orderInfo = order.value as? [String: Any] {
                                var singleOrder = Order(orderID: order.key,
                                                        cust_email: orderInfo["cust_email"] as! String,
                                                        cust_name: orderInfo["cust_name"] as! String,
                                                        date: orderInfo["date"] as! Double,
                                                        status_code: orderInfo["status_code"] as! Int)
                                if let orderItems = orderInfo["items"] as? [String: Any] {
                                    for item in orderItems {
                                        if let singleItem = item.value as? [String: Any] {
                                            singleOrder.orderItems.append(
                                                OrderItem(item_name: singleItem["item_name"] as! String,
                                                          price: singleItem["price"] as! Double))
                                        }
                                    }
                                }
                                
                                self.orderList.append(singleOrder)
                            }
                        }
                        
                        self.filteredOrders.append(contentsOf: self.orderList)
                        self.getOrderTotal()
                        self.tblOrders.reloadData()
                    } else {
                       let banner = NotificationBanner(title: "Error", subtitle: "No orders found", style: .danger)
                        banner.show()
                    }
                })
        }
    }

    extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredOrders.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tblOrders.dequeueReusableCell(withIdentifier: AccountTableViewCell.reuseIdentifier, for: indexPath) as! AccountTableViewCell
            cell.selectionStyle = .none
            cell.configXIB(order: filteredOrders[indexPath.row])
            return cell
        }
    }
