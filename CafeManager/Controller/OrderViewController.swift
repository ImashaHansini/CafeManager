//
//  OrderViewController.swift
//  CafeManager
//
//  Created by Imasha on 4/28/21.
//

import UIKit
import Firebase
import NotificationBannerSwift
import ProgressHUD

class OrderViewController: UIViewController {

    var orders: [Order] = []
    var filteredOrders: [Order] = []
    
    @IBOutlet weak var segTabs: UISegmentedControl!
    
    let databaseReference = Database.database().reference()

    @IBOutlet weak var tblOrders: UITableView!
      
    override func viewDidLoad() {
          super.viewDidLoad()
          tblOrders.register(UINib(nibName: OrderTableViewCell.nibName, bundle: nil), forCellReuseIdentifier:OrderTableViewCell.reuseIdentifier)
          // Do any additional setup after loading the view.
        ProgressHUD.animationType = .multipleCircleScaleRipple
        ProgressHUD.colorAnimation = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }
      
    override func viewDidAppear(_ animated: Bool) {
          self.fetchOrders()
    }

    @IBAction func onStatusSegChanged(_ sender: UISegmentedControl) {
      filterOrders(status: sender.selectedSegmentIndex)
        
    }
}

extension OrderViewController {
            
    func filterOrders(status: Int) {
        filteredOrders.removeAll()
        filteredOrders = self.orders.filter {$0.status_code == status}
        tblOrders.reloadData()
    }
    
    func fetchOrders() {
        ProgressHUD.show("Loading Orders!")
        self.filteredOrders.removeAll()
        self.orders.removeAll()
        self.databaseReference
            .child("orders")
            .observe(.value, with: {
                snapshot in
                ProgressHUD.dismiss()
                self.filteredOrders.removeAll()
                self.orders.removeAll()
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
                            
                            self.orders.append(singleOrder)
                        }
                    }
                    
                    self.filteredOrders.append(contentsOf: self.orders)
                    self.onStatusSegChanged(self.segTabs)
                } else {
                   let banner = NotificationBanner(title: "Error", subtitle: "No Orderes Found", style: .danger)
                    banner.show()
                }
            })
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblOrders.dequeueReusableCell(withIdentifier: OrderTableViewCell.reuseIdentifier, for: indexPath) as! OrderTableViewCell
        cell.selectionStyle = .none
        cell.configXIB(order: filteredOrders[indexPath.row])
        return cell
    }
}

