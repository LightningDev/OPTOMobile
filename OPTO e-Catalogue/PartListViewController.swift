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

protocol ParListViewDelegate {
    func partListView(controller: PartListViewController, saveOrder saved: Bool)
}

class PartListViewController: UIViewController {
    
    @IBOutlet weak var partlistView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var dateCreated: UILabel!
    var order = PendingOrder()
    var pendingorderView: PendingOrdersViewController? = nil
    var position = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteView!.layer.borderWidth = 1
        noteView!.layer.borderColor = UIColor.blue.cgColor
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
    
    @IBAction func unwindToPart(segue: UIStoryboardSegue) {
        partlistView.reloadData()
        updatePrice()
    }
    
    @IBAction func addAnother(sender: UIBarButtonItem) {
        add()
    }
    
    @IBAction func send() {
        // create the alert
        let alert = UIAlertController(title: "This order will be sent to OPTO!", message: "Do you want to send this order?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default,handler: { action in
            self.save()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func add() {
        if (order.customer != ApplicationUtilities.DefaultUser && ApplicationUtilities.DefaultUser != "") {
            let alert = UIAlertController(title: "Warning", message: "This action will change default user from \(ApplicationUtilities.DefaultUser) To \(order.customer)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                ApplicationUtilities.DefaultUser = self.order.customer
                ApplicationUtilities.switchCustomer = true
                self.tabBarController?.selectedIndex = 1
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            ApplicationUtilities.DefaultUser = self.order.customer
            tabBarController?.selectedIndex = 1
        }
    }
    
    func save() {
        let savedOrder = PendingOrder(value: order)
        savedOrder.send = true
        savedOrder.to_do = noteView.text!
        ServerUtilities.addPendingOrder(input: savedOrder)
        
//        ServerUtilities.sendPendingOrder(input: savedOrder) {
//            if (self.pendingorderView != nil) {
//                self.pendingorderView?.ordersView.reloadData()
//            }
//            self.order = PendingOrder()
//            self.title = "Part List"
//            self.noteView.text = ""
//            self.partlistView.reloadData()
//            self.updatePrice()
//        }
    }
    
    func load() {
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            pendingorderView = navController.topViewController as? PendingOrdersViewController
        }
        pendingorderView?.delegate = self
    }
    
    func updatePrice() {
        let price = ApplicationUtilities.splitString(input: order.sum_one)
        var sum = 0.0
        for i in 0..<price.count {
            sum += Double(price[i])!
        }
        totalPrice.text = String(sum)
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
        cell.price.text = "$ \(order.partList[indexPath.row].cash_p_m)"
        var _quantity = ApplicationUtilities.splitString(input: order.total_qty)
        cell.quantity.text = _quantity[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.partList.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let neworder = PendingOrder(value: order)
            neworder.partList.removeAll()
            neworder.partList.append(contentsOf: order.partList)
            ServerUtilities.deleteItem(inPendingOrder: neworder, partcode: order.partList[indexPath.row].code)
            partlistView.reloadData()
            updatePrice()
        }
    }
}

extension PartListViewController: PendingOrdersDelegate {
    func setOrderDetails(_ order: PendingOrder) {
        self.order = order
        self.title = order.customer
        partlistView.reloadData()
        sendButton.isEnabled = !(order.send)
        addButton.isEnabled = !(order.send)
        partlistView.allowsSelection = !(order.send)
        noteView.isHidden = order.send
        dateCreated.text = "Date and Time: \(order.opto_rcd_timestamp)"
        updatePrice()
    }
    
    func deleteOrderDetails() {
        self.order = PendingOrder()
        self.title = "Part List"
        self.noteView.text = ""
        partlistView.reloadData()
        updatePrice()
    }
}

extension PartListViewController: PartListDetailsDelegate {
    func setPartListDetails(controller: PartListDetailsViewController) {
        controller.position = position
        controller.load()
    }
}
