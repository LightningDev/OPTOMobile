//
//  POSTableCell.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 6/2/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit

class POSTableCell: UITableViewCell {
    @IBOutlet weak var barcode: UILabel!
    @IBOutlet weak var materialCode: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var qty: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var price: UILabel!
    
    func load(material: Material, barcode: String) {
        self.barcode.text = barcode
        self.materialCode.text = material.code
        self.desc.text = material.desc
        self.qty.text = "1"
        self.stock.text = "\(material.stock)"
        self.price.text = "$ \(material.cash_p_m)"
    }
}
