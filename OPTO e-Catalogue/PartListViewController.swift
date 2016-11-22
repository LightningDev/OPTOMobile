//
//  PartListViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 18/11/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

protocol PartListDetailsDelegate {
    func setPartListDetails(controller: PartListDetailsViewController)
}

class PartListViewController: UIViewController {
    
    @IBOutlet weak var partlistView: UITableView!
    var order = PendingOrder()
    var pendingorderView: PendingOrdersViewController? = nil
    var position = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partlistView.delegate = self
        self.partlistView.dataSource = self
        load()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePartDetails") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! PartListDetailsViewController
            topView.order = order
            topView.delegate = self
        }
    }
    
    @IBAction func goBackToList(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func send() {
        // create the alert
        let alert = UIAlertController(title: "UIAlertController", message: "Do you want to send the order?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default,handler: { action in
            self.save()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func save() {
        let savedOrder = PendingOrder(value: order)
        savedOrder.send = true
        ServerUtilities.addPendingOrder(input: savedOrder)
    }
    
    func load() {
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            pendingorderView = navController.topViewController as? PendingOrdersViewController
        }
        pendingorderView?.delegate = self
    }
}

extension PartListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        position = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartListCells", for: indexPath) as! PartListCell
        cell.partcode.text = order.partList[indexPath.row].code
        cell.desc.text = order.partList[indexPath.row].desc
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.partList.count
    }
    
}

extension PartListViewController: PendingOrdersDelegate {
    func setOrderDetails(_ order: PendingOrder) {
        self.order = order
        partlistView.reloadData()
    }
}

extension PartListViewController: PartListDetailsDelegate {
    func setPartListDetails(controller: PartListDetailsViewController) {
        controller.position = position
        controller.load()
    }
}
