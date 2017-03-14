//
//  HistoryDetailViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 8/3/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var detailView: UITableView!
    var numberOfItems = 0
    var partList = [Material]()
    var qtyList = [String]()
    var totalPriceList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detailView.delegate = self
        detailView.dataSource = self
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load() {
        numberOfItems = partList.count
        totalPriceLabel.text = "$ " + String(updatePrice())
        detailView.reloadData()
    }
    
    func updatePrice() -> Double {
        var sum = 0.0
        for i in 0..<totalPriceList.count {
            let price = totalPriceList[i]
            sum += Double(price)!
        }
        
        return sum
    }
}

extension HistoryDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension HistoryDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyDetailCells", for: indexPath) as! HistoryDetailCell
        if (!partList[indexPath.row].active) {
            cell.descLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 17.0)!
            cell.qtyLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 17.0)!
            cell.totalPriceLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 17.0)!
            cell.descLabel.textColor = UIColor.gray
            cell.qtyLabel.textColor = UIColor.gray
            cell.totalPriceLabel.textColor = UIColor.gray
        }
//        } else {
//            cell.descLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)!
//            cell.qtyLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)!
//            cell.totalPriceLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)!
//            cell.descLabel.textColor = UIColor.black
//            cell.qtyLabel.textColor = UIColor.black
//            cell.totalPriceLabel.textColor = UIColor.black
//        }
        cell.descLabel.text = partList[indexPath.row].desc
        cell.qtyLabel.text = qtyList[indexPath.row]
        cell.totalPriceLabel.text = "$ " + totalPriceList[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
}
