//
//  ItemDetailsViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 6/12/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit
import SDWebImage

protocol ItemDetailsViewControllerDelegate {
    func itemDetailsViewController(_ controller: ItemDetailsViewController)
}

class ItemDetailsViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var stockField: UITextField!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var plus: UIButton!
    var _code = ""
    var _desc = ""
    var _image = UIImage()
    var _stock = "0"
    var _stockfield = "0"
    var _price = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load() {
        code.text = _code
        desc.text = _desc
        stock.text = _stock
        stockField.text = _stockfield
        price.text = "$ \(_price)"
        if (_image != nil) {
            image.image = _image
        }
        let hidden = (ApplicationUtilities.DefaultUser == "")
        stockField.isHidden = hidden
        minus.isHidden = hidden
        plus.isHidden = hidden
        price.isHidden = hidden
        stock.isHidden = hidden
    }
    
    @IBAction func increaseQty(_ sender: UIButton) {
        let value: Int = Int(stockField.text!)! + 1
        let qty = stock.text!
        if (Double(qty)! > 0) {
            stockField.text = String(value)
            stock.text = String(Double(qty)! - 1.0)
        }
        modifyOrder()
    }
    
    @IBAction func decreaseQty(_ sender: UIButton) {
        var value: Int = Int(stockField.text!)!
        let qty = stock.text!
        if (value > 0) {
            value -= 1
        }
        stockField.text = String(value)
        stock.text = String(Double(qty)! + 1.0)
        modifyOrder()
    }
    
    func modifyOrder() {
        if (stockField.text != "0") {
            ApplicationUtilities.currentOrder[code.text!] = stockField.text!
            //ApplicationUtilities._currentOrder[code.text!] = priceLabel.text!
        } else {
            ApplicationUtilities.currentOrder.removeValue(forKey: code.text!)
            ApplicationUtilities._currentOrder.removeValue(forKey: code.text!)
        }
    }
}


