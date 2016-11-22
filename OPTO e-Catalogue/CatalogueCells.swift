//
//  CatalogueCells.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 15/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

class CatalogueCells: UICollectionViewCell {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var stockField: UITextField!
    @IBOutlet weak var stockQty: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addToCart: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func increaseQty(_ sender: UIButton) {
        let value: Int = Int(stockField.text!)! + 1
        let qty = stockQty.text!
        if (Double(qty)! >= 0) {
            stockField.text = String(value)
            stockQty.text = String(Double(qty)! - 1.0)
        }
    }
    
    @IBAction func decreaseQty(_ sender: UIButton) {
        var value: Int = Int(stockField.text!)!
        let qty = stockQty.text!
        if (value > 0) {
            value -= 1
        }
        stockField.text = String(value)
        stockQty.text = String(Double(qty)! + 1.0)
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        add()
    }
    
    func add() {
        let currentQty = stockQty.text!
        let code = codeLabel.text!
        let tax = ServerUtilities.defaultTax
        let discount = ServerUtilities.defaultDiscount
        let quantity = stockField.text!
        let price = priceLabel.text!
        let totalprice = (Double(price)! * Double(quantity)! * (100 - discount)) / 100
        let predicate = NSPredicate(format: "customer = %@", ApplicationUtilities.DefaultUser)
        let order = ServerUtilities.getPendingOrder(predicate: predicate).first
        
        let matcondition = NSPredicate(format: "code = %@", code)
        let result = ServerUtilities.getMaterial(predicate: matcondition).first
        let material = Material(value: result!)
        material.stock = Double(currentQty)!
        
        ServerUtilities.addMaterial(material: material)
        
        if (order != nil) {
            let oldOrder = PendingOrder(value: order!)
            oldOrder.part_code = (oldOrder.part_code) + ",\(code)"
            oldOrder.due_date_1 = (oldOrder.due_date_1) + ",\(NSDate())"
            oldOrder.sum_one = (oldOrder.sum_one) + ",\(totalprice)"
            oldOrder.tax_pro = (oldOrder.tax_pro) + ",\(tax)"
            oldOrder.total_amount_one = (oldOrder.total_amount_one) + ",\(price)"
            oldOrder.total_qty = (oldOrder.total_qty) + ",\(quantity)"
            oldOrder.ma = (oldOrder.ma) + ",\(discount)"
            oldOrder.partList.append(material)
            
            ServerUtilities.addPendingOrder(input: oldOrder)
        } else {
//            let sales = ServerUtilities.realm?.objects(SalesOrder.self)
//            let pending = ServerUtilities.realm?.objects(PendingOrder.self)
//            let _sorted = pending?.sorted(byProperty: "code", ascending: false).first
//            let sorted = sales?.sorted(byProperty: "code", ascending: false).first
            
            let pending = ServerUtilities.getPendingOrderSorted(ascending: false)
            let sales = ServerUtilities.getOrderSorted(ascending: false)
            
            var maxCode = (sales.first?.code)!
            if (pending.count > 0) {
                maxCode = (pending.first?.code)!
            }
            
            let newCode = Int(maxCode)! + 1
            let newOrder = PendingOrder()
            newOrder.code = String(newCode)
            newOrder.part_code = "\(code)"
            newOrder.due_date_1 = "\(NSDate())"
            newOrder.sum_one = "\(totalprice)"
            newOrder.tax_pro = "\(tax)"
            newOrder.total_amount_one = "\(price)"
            newOrder.total_qty = "\(quantity)"
            newOrder.ma = "\(discount)"
            newOrder.customer = ApplicationUtilities.DefaultUser
            
            newOrder.partList.append(material)
            
            ServerUtilities.addPendingOrder(input: newOrder)
        }
    }
}
