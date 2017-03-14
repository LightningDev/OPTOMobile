//
//  ContactDetailsViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 14/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactCode: UILabel!
    @IBOutlet weak var contactType: UILabel!
    @IBOutlet weak var contactPhone: UITextField!
    @IBOutlet weak var contactEmail: UITextField!
    @IBOutlet weak var contactWebsite: UITextField!
    @IBOutlet weak var deliveryAddress: UITextField!
    @IBOutlet weak var postalAddress: UITextField!
    
    var contactView: ContactViewController? = nil
    var contact = Contact()
    
    @IBAction func setContactDefault(_ sender: UIBarButtonItem) {
        ApplicationUtilities.DefaultUser = contact.code
        let alert = UIAlertController(title: "Customer Selection", message: "You have select \(contact.name) as a default customer.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func showHistory(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueToHistory", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            contactView = navController.topViewController as? ContactViewController
        }
        contactView?.delegate = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToHistory") {
            if let destination = segue.destination as? UINavigationController {
                let predicate = NSPredicate(format: "customer = '\(contactCode.text!)'")
                let history = destination.topViewController as! HistoryViewController
                history.orders = ServerUtilities.getPendingOrder(predicate: predicate)
            }
        }
    }
}

extension ContactDetailsViewController: ContactDelegate {
    func setContactDetails(_ contact: Contact) {
        contactName.text = contact.name
        contactCode.text = contact.code
        contactEmail.text = contact.email
        contactPhone.text = contact.phone
        contactWebsite.text = contact.website
        deliveryAddress.text = contact.delivery_address_1
        postalAddress.text = contact.postal_address_1
        contactType.text = String(contact.name[contact.name.startIndex]).uppercased()
        self.contact = contact
    }
}
