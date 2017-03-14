//
//  PendingOrdersViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 18/11/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

protocol PendingOrdersDelegate {
    func setOrderDetails(_ order: PendingOrder)
    func deleteOrderDetails()
}


class PendingOrdersViewController: UIViewController {
    
    @IBOutlet weak var ordersView: UITableView!
    var filterButton = UIBarButtonItem()
    var orders = [PendingOrder]()
    var delegate: PendingOrdersDelegate? = nil
    var selectedOrder: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersView.delegate = self
        ordersView.dataSource = self
        //load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
    }
    
    @IBAction func refresh() {
        load()
    }
    
    func setup() {
        
    }

    func load() {
        orders.removeAll()
        let predicate = NSPredicate(format: "employee = '\(ApplicationUtilities.loginUser)'")
        orders = ServerUtilities.getPendingOrder(predicate: predicate)
        //orders = ServerUtilities.getPendingOrder()
        ordersView.reloadData()
    }
    
    func delete() {
        orders.remove(at: selectedOrder)
        ordersView.reloadData()
    }
}

extension PendingOrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        selectedOrder = indexPath.row
        if (delegate != nil) {
            delegate?.setOrderDetails(order)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingOrderCells", for: indexPath) as! PendingOdersCell
        if (orders[indexPath.row].send) {
            cell.textLabel?.text = "\(orders[indexPath.row].code) / \(orders[indexPath.row].opto_rcd)"
            cell.textLabel?.textColor = UIColor.green
        } else {
            cell.textLabel?.text = orders[indexPath.row].code
            cell.textLabel?.textColor = UIColor.black
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ServerUtilities.deleteOrder(pending: orders[indexPath.row])
            orders.remove(at: indexPath.row)
            ordersView.reloadData()
            if (delegate != nil) {
                delegate?.deleteOrderDetails()
            }
        }
    }

}
