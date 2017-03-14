//
//  SettingsPopOverController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 23/1/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit

class SettingsPopOverController: UIViewController {
    
    @IBOutlet weak var realmIP: UITextField!
    @IBOutlet weak var optoIP: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    @IBAction func save(sender: UIButton) {
        ServerUtilities.realmIP = realmIP.text!
        ServerUtilities.optoIP = optoIP.text!
        self.dismiss(animated: true, completion: nil)
    }
    
    func load() {
        realmIP.text = ServerUtilities.realmIP
        optoIP.text = ServerUtilities.optoIP
    }
}
