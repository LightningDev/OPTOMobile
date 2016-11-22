//
//  ContactList.swift
//  Catalog
//
//  Created by Nhat Tran on 13/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import UIKit

protocol ContactDelegate {
    func setContactDetails(_ contact: Contact)
}

class ContactViewController: UIViewController {
    @IBOutlet weak var contactView: UITableView!
    let alphaIndex = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    var alpha = [String:Int]()
    var alphaContacts = [String: [Int]]()
    var contacts = [Contact]()
    var numberOfItems = 0
    var delegate: ContactDelegate? = nil
    
    // Online - unstable
    let checkOnline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactView.delegate = self
        self.contactView.dataSource = self
        load()
    }
    
    func load() {
        contacts.removeAll()
        contacts = ServerUtilities.getContactSorted()
        numberOfItems = contacts.count
        sorted()
        self.contactView.reloadData()
    }
    
    func sorted() {
        for i in 0..<numberOfItems {
            let name = contacts[i].name
            var char = String(name[name.startIndex]).uppercased()
            if (!alphaIndex.contains(char)) {
                char = "#"
            }
            if (alpha[char] != nil) {
                alpha[char] = alpha[char]! + 1
                alphaContacts[char]?.append(i)
            } else {
                alpha[char] = 1
                alphaContacts[char] = [Int]()
                alphaContacts[char]?.append(i)
            }
        }
    }
}

extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rows = alphaContacts[alphaIndex[indexPath.section]]!
        if (delegate != nil) {
            delegate?.setContactDetails(contacts[rows[indexPath.row]])
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return alphaIndex
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCells", for: indexPath) as! ContactCell
        let rows = alphaContacts[alphaIndex[indexPath.section]]!
        cell.nameLabel.text = contacts[rows[indexPath.row]].name
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return alphaIndex.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (alpha[alphaIndex[section]] == nil) {
            return 0
        }
        return alpha[alphaIndex[section]]!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alphaIndex[section]
    }
}

