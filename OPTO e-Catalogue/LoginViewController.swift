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
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var employeeView: UITableView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    var optoUser = [OPTOUser]()
    var numberOfItems = 0
    var employeeNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        employeeView.delegate = self
        employeeView.dataSource = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.optoUser = ServerUtilities.getOPTOUSer()
        self.numberOfItems = self.optoUser.count
        self.employeeView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        if (employeeNumber != "" && passwordTextField.text != "") {
            if (ServerUtilities.loginLocal(employee: employeeNumber, password: passwordTextField.text!)) {
                ApplicationUtilities.loginUser = employeeNumber
                self.performSegue(withIdentifier: "segueToMainMenu", sender: self)
            }
        }
    }
    
    func setupUI() {
        loginView.layer.cornerRadius = 5
        loginView.layer.borderWidth = 1
        
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(red:0.08, green:0.40, blue:0.78, alpha:0.7).cgColor
        passwordTextField.isEnabled = false
        
        loginButton.layer.cornerRadius = 5
        employeeView.layer.cornerRadius = 5
        employeeView.layer.borderWidth = 1
        employeeView.layer.borderColor = UIColor(red:0.08, green:0.40, blue:0.78, alpha:0.7).cgColor
    }
   
}

extension LoginViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        passwordTextField.text = ""
        passwordTextField.isEnabled = true
        employeeNumber = optoUser[indexPath.row].employee
    }
}

extension LoginViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OPTOUserRows", for: indexPath) as! OPTOUserCell
        let empNumber = optoUser[indexPath.row].employee
        let predicate = NSPredicate(format: "code = '\(empNumber)'")
        let name = ServerUtilities.realm?.objects(Employee.self).filter(predicate).first?.name
        cell.employeeNumber.text = optoUser[indexPath.row].employee + " - " + name!
        return cell
    }
}
