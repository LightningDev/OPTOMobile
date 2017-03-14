//
//  HistoryViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 7/3/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var historyView: UITableView!
    @IBOutlet weak var borderView: UIView!
    var orders = [PendingOrder]()
    var numberOfItems = 0
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        historyView.delegate = self
        historyView.dataSource = self
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToHistoryDetail") {
            if let destination = segue.destination as? HistoryDetailViewController {
                let order = orders[(historyView.indexPathForSelectedRow?.row)!]
                destination.partList = Array(order.partList)
                destination.qtyList = ApplicationUtilities.splitString(input: order.total_qty)
                destination.totalPriceList = ApplicationUtilities.splitString(input: order.sum_one)
            }
        }
    }
    
    @IBAction func closeWindow(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func load() {
        numberOfItems = orders.count
        historyView.reloadData()
    }
    
    func setupUI() {
        borderView.layer.cornerRadius = 5
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor(red:0.08, green:0.40, blue:0.78, alpha:0.7).cgColor
    }
    
    func updatePrice(input: [String]) -> Double {
        var sum = 0.0
        for i in 0..<input.count {
            let price = input[i]
            sum += Double(price)!
        }
        
        return sum
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToHistoryDetail", sender: nil)
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyOrderCells", for: indexPath) as! HistoryCell
        let order = orders[indexPath.row]
        cell.codeLabel.text = orders[indexPath.row].code
        cell.optoCodeLabel.text = orders[indexPath.row].opto_rcd
        cell.dateLabel.text = orders[indexPath.row].opto_rcd_timestamp
        cell.priceLabel.text = "$ " + String(updatePrice(input: ApplicationUtilities.splitString(input: order.sum_one)))
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
}
