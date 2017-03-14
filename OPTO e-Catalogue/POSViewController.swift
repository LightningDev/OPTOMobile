//
//  POSViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 14/12/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

protocol POSViewControllerDelegate {
    func posViewController(typingBarcode: String)
    func posViewController(enabledField: Bool)
}

class POSViewController: UIViewController{
    
    @IBOutlet weak var posView: UITableView!
    @IBOutlet weak var materialCode: BarcodeTextfield!
    @IBOutlet weak var customerButton: UIBarButtonItem!
    var temporaryBarcode = [String]()
    var order = [Material]()
    var numberOfItems = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posView.delegate = self
        posView.dataSource = self
        materialCode._delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customerButton.title = "Select Customer"
        if (ApplicationUtilities.DefaultUser != "") {
            customerButton.title = "\(ApplicationUtilities.DefaultUser)"
        }
        materialCode.becomeFirstResponder()
    }
    
    @IBAction func add() {
        if (ApplicationUtilities.DefaultUser != "") {
            let code = ApplicationUtilities.createOrder()
            let alert = UIAlertController(title: "Order of customer \(customerButton.title!)", message: "Please check order \(code)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            ApplicationUtilities.DefaultUser = ""
            customerButton.title = "Select Customer"
            order.removeAll()
            numberOfItems = order.count
            posView.reloadData()
        } else {
            let alert = UIAlertController(title: "Warning", message: "Please Select Customer", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reset() {
        resetOrder()
    }
    
    func searchBarcode(code: String) -> Material {
        let materials = ServerUtilities.getMaterial()
        let code = materialCode.text!
        var output = Material()
        
        for i in 0..<materials.count {
            let codes = ApplicationUtilities.splitString(input: materials[i].barcode)
            if (codes.contains(code)) {
                output = materials[i]
                break
            } else {
                if (code == materials[i].code) {
                    output = materials[i]
                    break
                }
            }
        }
        
        return output
    }
    
    func updateOrder() {
        let code = materialCode.text!
        let predicate = NSPredicate(format: "barcode = %@", code)
        let material = ServerUtilities.getMaterial(predicate: predicate).first
        order.append(material!)
        numberOfItems = order.count
        posView.reloadData()
    }
    
    func resetOrder() {
        order.removeAll()
        numberOfItems = order.count
        ApplicationUtilities.currentOrder.removeAll()
        posView.reloadData()
    }
}


extension POSViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension POSViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "POSCells", for: indexPath) as! POSTableCell
        cell.load(material: order[indexPath.row], barcode: temporaryBarcode[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ApplicationUtilities.currentOrder.removeValue(forKey: order[indexPath.row].code)
            order.remove(at: indexPath.row)
            temporaryBarcode.remove(at: indexPath.row)
            numberOfItems = order.count
            posView.reloadData()
        }
    }
    
}

extension POSViewController: POSViewControllerDelegate {
    
    func posViewController(typingBarcode: String) {
        let material = searchBarcode(code: typingBarcode)
        if (material.code != "") {
            ApplicationUtilities.currentOrder[material.code] = "1"
            order.append(material)
            numberOfItems = order.count
            temporaryBarcode.append(typingBarcode)
            posView.reloadData()
        }
    }
    
    func posViewController(enabledField: Bool) {
        materialCode.isEnabled = enabledField
        if (enabledField) {
            materialCode.becomeFirstResponder()
        }
    }
}
