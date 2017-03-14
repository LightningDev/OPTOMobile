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
    @IBOutlet weak var _priceLabel: UILabel!
    @IBOutlet weak var _stockQty: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    var delegate: CatalogueViewCellDelegate? = nil
    var checked: Bool = false
    
    @IBAction func increaseQty(_ sender: UIButton) {
        let value: Int = Int(stockField.text!)! + 1
        let qty = stockQty.text!
        let outstock = delegate?.checkOutOfStock()
        if (Double(qty)! > 0 || outstock!) {
            stockField.text = String(value)
            if (!(outstock!)) {
                stockQty.text = String(Double(qty)! - 1.0)
            }
        }
        modifyOrder()
    }
    
    @IBAction func decreaseQty(_ sender: UIButton) {
        var value: Int = Int(stockField.text!)!
        let qty = stockQty.text!
        if (value > 0) {
            value -= 1
        }
        let outstock = delegate?.checkOutOfStock()
        stockField.text = String(value)
        if (!(outstock!)) {
            stockQty.text = String(Double(qty)! + 1.0)
        }
        modifyOrder()
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        //add()
    }
    
    @IBAction func setImage(_ sender: UIButton) {
        ApplicationUtilities.selectedCell = self
        if (delegate != nil) {
            delegate?.performSegueManually(identifier: "segueMatdetails" )
        }
    }
    
    @IBAction func check(_ sender: UIButton) {
        checkBoxChecked()
        //print(checked)
        checked = !checked
        delegate?.catalogueCell(self)
    }
    
    func checkBoxChecked() {
        if (checked) {
            checkBox.setImage(UIImage(named: "UncheckBox"), for: .normal)
        } else {
            checkBox.setImage(UIImage(named: "CheckBox"), for: .normal)
        }
    }
    
    func hideDetails(input: Bool) {
        checkBox.isHidden = true
        let value = !(ApplicationUtilities.DefaultUser != "")
        if (value) {
            checkBox.isHidden = !input
        }
        priceLabel.isHidden = value
        minusButton.isHidden = value
        plusButton.isHidden = value
        stockField.isHidden = value
        stockQty.isHidden = value
        _priceLabel.isHidden = value
        _stockQty.isHidden = value
    }
    
    func load(material: Material, row: Bool) {
        //hideDetails()
        stockField.keyboardType = UIKeyboardType.numberPad
        let code = material.code
        codeLabel.text = code
        descLabel.text = material.desc
        priceLabel.text = String(material.cash_p_m)
        let stock = material.stock
        if (stock > 0) {
            stockQty.textColor = UIColor.green
        } else {
            stockQty.textColor = UIColor.red
        }
        if (ApplicationUtilities.currentOrder[code] != nil) {
            stockField.text = ApplicationUtilities.currentOrder[code]
        } else {
            stockField.text = "0"
        }
        if (!row) {
            checkBox.setImage(UIImage(named: "UncheckBox"), for: .normal)
        } else {
            checkBox.setImage(UIImage(named: "CheckBox"), for: .normal)
        }
        stockQty.text = String(Double(stock) - Double(stockField.text!)!)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        let destination = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("OPTOImages")
        let imageURL = "\(destination)/\(code).jpg"
        if FileManager.default.fileExists(atPath: imageURL) {
            let image    = UIImage(contentsOfFile: imageURL)
            myImage.image = image
        } else {
            //let url = URL(string: "http://\(ServerUtilities.optoIP)/images/\(code).jpg")
            let url = URL(string: "\(ServerUtilities.customerImagesURL)/\(code).jpg")
            myImage.sd_setImage(with: url!, placeholderImage: UIImage(named: "\(code).jpg"))
        }
    }
    
    func modifyOrder() {
        if (stockField.text != "0") {
            ApplicationUtilities.currentOrder[codeLabel.text!] = stockField.text!
            ApplicationUtilities._currentOrder[codeLabel.text!] = priceLabel.text!
        } else {
            ApplicationUtilities.currentOrder.removeValue(forKey: codeLabel.text!)
            ApplicationUtilities._currentOrder.removeValue(forKey: codeLabel.text!)
        }
        if (delegate != nil) {
            delegate?.updatePrice(price: ApplicationUtilities.updatePrice())
        }
    }
    
//    func add() {
//        if (ApplicationUtilities.DefaultUser != "") {
//            let currentQty = stockQty.text!
//            let code = codeLabel.text!
//            let tax = ServerUtilities.defaultTax
//            let discount = ServerUtilities.defaultDiscount
//            let quantity = stockField.text!
//            let price = priceLabel.text!
//            let totalprice = (Double(price)! * Double(quantity)! * (100 - discount)) / 100
//            let predicate = NSPredicate(format: "customer = %@", ApplicationUtilities.DefaultUser)
//            let order = ServerUtilities.getPendingOrder(predicate: predicate).first
//            let styler = DateFormatter()
//            styler.dateFormat = "MM/dd/yy"
//            let date = styler.string(from: NSDate() as Date)
//            let matcondition = NSPredicate(format: "code = %@", code)
//            let result = ServerUtilities.getMaterial(predicate: matcondition).first
//            let material = Material(value: result!)
//            material.stock = Double(currentQty)!
//            
//            ServerUtilities.addMaterial(material: material)
//            
//            if (order != nil) {
//                let oldOrder = PendingOrder(value: order!)
//                oldOrder.part_code = (oldOrder.part_code) + ",\(code)"
//                oldOrder.due_date_1 = (oldOrder.due_date_1) + ",\(date)"
//                oldOrder.sum_one = (oldOrder.sum_one) + ",\(totalprice)"
//                oldOrder.tax_pro = (oldOrder.tax_pro) + ",\(tax)"
//                oldOrder.total_amount_one = (oldOrder.total_amount_one) + ",\(price)"
//                oldOrder.total_qty = (oldOrder.total_qty) +
//                ",\(quantity)"
//                oldOrder.ma = (oldOrder.ma) + ",\(discount)"
//                oldOrder.partList.append(material)
//                
//                ServerUtilities.addPendingOrder(input: oldOrder)
//            } else {
//                
//                let pending = ServerUtilities.getPendingOrderSorted(ascending: false)
//                let sales = ServerUtilities.getOrderSorted(ascending: false)
//                
//                var maxCode = (sales.first?.code)!
//                if (pending.count > 0) {
//                    maxCode = (pending.first?.code)!
//                }
//                maxCode = maxCode.replacingOccurrences(of: "\n", with: "")
//                let newCode = Int(maxCode)! + 1
//                let newOrder = PendingOrder()
//                newOrder.code = String(newCode)
//                newOrder.part_code = "\(code)"
//                newOrder.due_date_1 = "\(date)"
//                newOrder.sum_one = "\(totalprice)"
//                newOrder.tax_pro = "\(tax)"
//                newOrder.total_amount_one = "\(price)"
//                newOrder.total_qty = "\(quantity)"
//                newOrder.ma = "\(discount)"
//                newOrder.customer = ApplicationUtilities.DefaultUser
//                newOrder.employee = ApplicationUtilities.loginUser
//                
//                newOrder.partList.append(material)
//                
//                ServerUtilities.addPendingOrder(input: newOrder)
//            }
//            if (delegate != nil) {
//                let alert = UIAlertController(title: "Alert", message: "\(code) is added to cart", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                delegate?.showAlert(controller: alert)
//            }
//        } else {
//            if (delegate != nil) {
//                let alert = UIAlertController(title: "Alert", message: "Please Select Customer", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                delegate?.showAlert(controller: alert)
//            }
//        }
//    }
}

