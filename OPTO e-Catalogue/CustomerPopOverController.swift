//
//  CustomerPopOverController.swift
//  Catalog
//
//  Created by Nhat Tran on 19/10/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

protocol CustomerPopOverDelegate {
    func setCustomer()
}

class CustomerPopOverController: UIViewController {
    
    @IBOutlet weak var customerView: UITableView!
    @IBOutlet weak var searchBars: UISearchBar!
    
    var contact = [Contact]()
    var numberOfItems = 0
    var delegate: CustomerPopOverDelegate? = nil
    var _delegate: CatalogueViewCellDelegate? = nil
    var filterIndexes = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerView.delegate = self
        customerView.dataSource = self
        searchBars.delegate = self
        load()
    }
    
    func load() {
        contact.removeAll()
        let predicate = NSPredicate(format: "employee = %@", ApplicationUtilities.loginUser)
        contact = ServerUtilities.getContactSorted(predicate: predicate)
        numberOfItems = contact.count
        customerView.reloadData()
    }
    
    @IBAction func clearCustomer(sender: UIBarButtonItem) {
        ApplicationUtilities.DefaultUser = ""
        if (self.delegate != nil) {
            self.delegate?.setCustomer()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func filter(search: String) {
        filterIndexes.removeAll()
        for i in 0..<contact.count {
            let searchLowercase = search.lowercased()
            let code = contact[i].code.lowercased()
            let desc = contact[i].name.lowercased()
            if (code.contains(searchLowercase) || desc.contains(searchLowercase)) {
                self.filterIndexes.append(i)
            }
        }
    }
}

extension CustomerPopOverController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterIndexes.removeAll()
        numberOfItems = contact.count
        customerView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            filterIndexes.removeAll()
            numberOfItems = contact.count
            customerView.reloadData()
        } else {
            let searchText = searchBar.text!
            filter(search: searchText)
            numberOfItems = filterIndexes.count
            customerView.reloadData()
        }
    }
}

extension CustomerPopOverController: UITableViewDelegate {
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ApplicationUtilities.DefaultUser = self.contact[indexPath.row].code
        if (self.delegate != nil) {
            self.delegate?.setCustomer()
        }
        if (!ApplicationUtilities.currentOrder.isEmpty) {
            _ = ApplicationUtilities.createOrder()
            _delegate?.resetViewController()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomerPopOverController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customerView.dequeueReusableCell(withIdentifier: "CustomerCells", for: indexPath) as! CustomerPopOverCell
        
        cell.customerName.text = contact[indexPath.row].name
        if (contact[indexPath.row].code == ApplicationUtilities.DefaultUser) {
            cell.customerName.textColor = UIColor.green
        } else {
            cell.customerName.textColor = UIColor.black
        }
        
        return cell
    }
}

