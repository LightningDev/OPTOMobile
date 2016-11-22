//
//  GroupPopOverController.swift
//  Catalog
//
//  Created by Nhat Tran on 18/10/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class GroupPopOverController: UITableViewController {
    
    var group = [Group]()
    var numberOfItems = 0
    var _delegate: CatalogueViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (_delegate != nil) {
            _delegate?.setCollectionViewController(controller: self, index: indexPath.row)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCells", for: indexPath) as! GroupPopOverCell
        cell.groupName.text = group[indexPath.row].desc
        return cell
    }
    
    func load() {
        group.removeAll()
        group = ServerUtilities.getGroup(type: ApplicationUtilities.CurrentGroup)
        numberOfItems = group.count
        self.tableView.reloadData()
    }
    
}
