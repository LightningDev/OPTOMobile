//
//  NewContactViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 16/12/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

class NewContactViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var _address: UILabel!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var _city: UILabel!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var _state: UILabel!
    @IBOutlet weak var postcode: UITextField!
    @IBOutlet weak var _postcode: UILabel!
    @IBOutlet weak var type: UILabel!
    
    var deliveryAddress = [String]()
    var postalAddress = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        let contact = Contact()
        contact.employee = ApplicationUtilities.loginUser
        contact.name = name.text!
        contact.phone = phone.text!
        contact.email = email.text!
        contact.code = "\(contact.name.trimmingCharacters(in: .whitespaces))-\(ApplicationUtilities.loginUser)"
        if (!postalAddress.isEmpty) {
            contact.postal_address_1 = postalAddress[0]
            contact.postal_city = postalAddress[1]
            contact.postal_state = postalAddress[2]
            contact.postal_postcode = postalAddress[3]
        }
        
        if (!deliveryAddress.isEmpty) {
            contact.delivery_address_1 = deliveryAddress[0]
            contact.delivery_city = deliveryAddress[1]
            contact.delivery_state = deliveryAddress[2]
            contact.delivery_postcode = deliveryAddress[3]
        }
        ServerUtilities.addContact(contact: contact)
        performSegue(withIdentifier: "segueContact", sender: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "segueContact", sender: nil)
    }
    
    @IBAction func switchAddress(sender: UISwitch) {
        if (sender.isOn) {
            deliveryAddress.removeAll()
            deliveryAddress.append(address.text!)
            deliveryAddress.append(city.text!)
            deliveryAddress.append(state.text!)
            deliveryAddress.append(postcode.text!)
            _address.text = "Postal Address"
            _city.text = "Postal City"
            _state.text = "Postal State"
            _postcode.text = "Postal Postcode"
            type.text = "Postal Address"
            address.text = ""
            city.text = ""
            postcode.text = ""
            state.text = ""
            if (!postalAddress.isEmpty) {
                address.text = postalAddress[0]
                city.text = postalAddress[1]
                postcode.text = postalAddress[3]
                state.text = postalAddress[2]
            }
        } else {
            postalAddress.removeAll()
            postalAddress.append(address.text!)
            postalAddress.append(city.text!)
            postalAddress.append(state.text!)
            postalAddress.append(postcode.text!)
            _address.text = "Delivery Address"
            _city.text = "Delivery City"
            _state.text = "Delivery State"
            _postcode.text = "Delivery Postcode"
            type.text = "Delivery Address"
            address.text = ""
            city.text = ""
            postcode.text = ""
            state.text = ""
            if (!deliveryAddress.isEmpty) {
                address.text = deliveryAddress[0]
                city.text = deliveryAddress[1]
                postcode.text = deliveryAddress[3]
                state.text = deliveryAddress[2]
            }
        }
    }
}
