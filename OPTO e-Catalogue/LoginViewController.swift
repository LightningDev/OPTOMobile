//
//  LoginViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 8/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var noticeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        let username = ServerUtilities.realmUsername
        let password = ServerUtilities.realmPassword
        let employee = usernameTextField.text
        let empPassword = passwordTextField.text
        let connection = ServerUtilities.isConnectedToNetwork()
        if (connection) {
            noticeLabel.text = "Connecting to Server..."
            ServerUtilities.login(username: username, password: password, action: .useExistingAccount) {
                if (ServerUtilities.realm != nil) {
                    self.noticeLabel.text = "Connected!"
                    self.noticeLabel.text = "Authenticating..."
                    if (ServerUtilities.loginLocal(employee: employee!, password: empPassword!)) {
                        self.noticeLabel.text = "Authenticated!"
                        self.performSegue(withIdentifier: "segueToMainMenu", sender: self)
                    } else {
                        self.noticeLabel.text = "Something wrong with employee account..."
                    }
                } else {
                    self.noticeLabel.text = "Something wrong with either server or credential..."
                }
            }
        } else {
            noticeLabel.text = "Checking Saved Credential..."
            if (ServerUtilities.loginLocal(employee: employee!, password: empPassword!)) {
                self.noticeLabel.text = "Authenticated!"
                self.performSegue(withIdentifier: "segueToMainMenu", sender: self)
            } else {
                self.noticeLabel.text = "Something wrong with credential..."
            }
        }
    }
    
    @IBAction func testOffline() {
        let contact = ServerUtilities.getContact()
        //print(ServerUtilities.realm?.configuration.)
        print(contact.count)
    }
}
