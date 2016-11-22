//
//  PartListDetailsViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 18/11/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

class PartListDetailsViewController: UIViewController {
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var duedate: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var unitprice: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var tax: UITextField!
    @IBOutlet weak var total: UITextField!
    var order = PendingOrder()
    var position = -1
    var delegate: PartListDetailsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (delegate != nil) {
            delegate?.setPartListDetails(controller: self)
        }
    }
    
    @IBAction func goBackToList(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goBackToList", sender: self)
    }
    
    @IBAction func save() {
        edited()
    }
    
    func edited() {
        if (position >= 0) {
            
            var _duedate = ApplicationUtilities.splitString(input: order.due_date_1)
            var _unitprice = ApplicationUtilities.splitString(input: order.total_amount_one)
            var _quantity = ApplicationUtilities.splitString(input: order.total_qty)
            var _tax = ApplicationUtilities.splitString(input: order.tax_pro)
            var _discount = ApplicationUtilities.splitString(input: order.ma)
            var _total = ApplicationUtilities.splitString(input: order.sum_one)
            
            _duedate[position] = duedate.text!
            _unitprice[position] = unitprice.text!
            _quantity[position] = quantity.text!
            _tax[position] = tax.text!
            _discount[position] = discount.text!
            _total[position] = total.text!
            
            let newOrder = PendingOrder(value: order)
            newOrder.due_date_1 = ApplicationUtilities.appendArray(input: _duedate)
            newOrder.total_amount_one = ApplicationUtilities.appendArray(input: _unitprice)
            newOrder.total_qty = ApplicationUtilities.appendArray(input: _quantity)
            newOrder.tax_pro = ApplicationUtilities.appendArray(input: _tax)
            newOrder.ma = ApplicationUtilities.appendArray(input: _discount)
            newOrder.sum_one = ApplicationUtilities.appendArray(input: _total)
            ServerUtilities.addPendingOrder(input: newOrder)
        }
    }
    
    func load() {
        var _duedate = ApplicationUtilities.splitString(input: order.due_date_1)
        var _unitprice = ApplicationUtilities.splitString(input: order.total_amount_one)
        var _quantity = ApplicationUtilities.splitString(input: order.total_qty)
        var _tax = ApplicationUtilities.splitString(input: order.tax_pro)
        var _discount = ApplicationUtilities.splitString(input: order.ma)
        var _code = ApplicationUtilities.splitString(input: order.part_code)
        
        duedate.text = _duedate[position]
        unitprice.text = _unitprice[position]
        quantity.text = _quantity[position]
        tax.text = _tax[position]
        discount.text = _discount[position]
        code.text = _code[position]
        name.text = order.partList[position].desc
        
        let totalprice = (Double(unitprice.text!)! * Double(quantity.text!)! * (100 - Double(discount.text!)!)) / 100
        total.text = String(totalprice)
    }
}
