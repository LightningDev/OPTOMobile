//
//  CustomerPopOverController.swift
//  Catalog
//
//  Created by Nhat Tran on 19/10/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class CustomerPopOverController: UITableViewController {
    
    var contact = [Contact]()
    var numberOfItems = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load() {
        contact.removeAll()
        contact = ServerUtilities.getContact()
        numberOfItems = contact.count
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ApplicationUtilities.DefaultUser = contact[indexPath.row].name
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCells", for: indexPath) as! CustomerPopOverCell
        
        cell.customerName.text = contact[indexPath.row].name
        if (cell.customerName.text == ApplicationUtilities.DefaultUser) {
            cell.customerName.textColor = UIColor.green
        } else {
            cell.customerName.textColor = UIColor.black
        }

        return cell
    }
    
    
}
