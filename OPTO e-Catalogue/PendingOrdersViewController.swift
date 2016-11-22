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
}


class PendingOrdersViewController: UIViewController {
    
    @IBOutlet weak var ordersView: UITableView!
    var orders = [PendingOrder]()
    var delegate: PendingOrdersDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersView.delegate = self
        ordersView.dataSource = self
        load()
    }
    
    @IBAction func refresh() {
        load()
    }

    func load() {
        orders.removeAll()
        orders = ServerUtilities.getPendingOrder()
        ordersView.reloadData()
    }
}

extension PendingOrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        if (delegate != nil) {
            delegate?.setOrderDetails(order)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingOrderCells", for: indexPath) as! PendingOdersCell
        cell.textLabel?.text = orders[indexPath.row].code
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

}
