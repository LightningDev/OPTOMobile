//
//  SettingsViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 9/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sync() {
        ServerUtilities.syncOPTOUser()
//        self.syncGroup()
//        self.syncMaterial()
//        self.syncOrder()
//        self.syncContact()

    }
    
    func syncGroup() {
        let list = ServerUtilities.getGroup()
        ServerUtilities.syncGroup(group: list)
    }
    
    func syncMaterial() {
        let list = ServerUtilities.getMaterial()
        ServerUtilities.syncMaterial(material: list)
    }
    
    func syncOrder() {
        let list = ServerUtilities.getOrder()
        ServerUtilities.syncOrder(order: list)
    }
    
    func syncContact() {
        let list = ServerUtilities.getContact()
        ServerUtilities.syncContact(contact: list)
    }
}
