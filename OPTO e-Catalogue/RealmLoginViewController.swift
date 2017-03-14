//
//  RealmLoginViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 1/3/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class RealmLoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var spinningView: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        enableUI(trigger: false)
        login()
    }
    
    func enableUI(trigger: Bool) {
        usernameField.isEnabled = trigger
        passwordField.isEnabled = trigger
        loginButton.isEnabled = trigger
        if (!trigger) {
            spinningView.startAnimating()
        } else {
            spinningView.stopAnimating()
        }
        loginView.isHidden = trigger
    }
    
    func setupUI() {
        usernameView.layer.cornerRadius = 5
        usernameView.layer.borderWidth = 1
        usernameView.layer.borderColor = UIColor(red:0.08, green:0.40, blue:0.78, alpha:0.7).cgColor
        
        passwordView.layer.cornerRadius = 5
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor(red:0.08, green:0.40, blue:0.78, alpha:0.7).cgColor
        
    }
    
    func checkLogin() {
        if (SyncUser.current != nil) {
            //enableUI(trigger: false)
            login()
        }
    }
    
    func login() {
        let username = usernameField.text!
        let password = passwordField.text!
        let customer = username.characters.split{$0 == "@"}.map(String.init)[0]
        let loginDispatch = DispatchGroup()
        ServerUtilities.login(username: username, password: password, register: false, dispatch: loginDispatch)
        loginDispatch.notify(queue: DispatchQueue.main) {
            if (ServerUtilities.realmConfiguration != nil) {
                ServerUtilities.realm = try! Realm(configuration: ServerUtilities.realmConfiguration!)
            }
            ApplicationUtilities.loginUser = "1"
            ServerUtilities.customerImagesURL = "http://199.229.252.219:8000/\(customer)"
            
            //let users = ServerUtilities.realm?.objects(OPTOUser.self).first
            //ServerUtilities.notificationDownload()
            self.enableUI(trigger: true)
            self.performSegue(withIdentifier: "segueToSync", sender: self)
        }
    }
}
