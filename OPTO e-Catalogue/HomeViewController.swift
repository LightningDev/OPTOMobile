//
//  HomeViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 9/12/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    let session = SyncUser.current!.allSessions()[0]
    var token: SyncSession.ProgressNotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        //ServerUtilities.logout()
        performSegue(withIdentifier: "segueToLogin", sender: nil)
    }
    
    @IBAction func check(sender: UIBarButtonItem) {
        self.token = session.addProgressNotification(for: .download, mode: .reportIndefinitely) {
            progress in
            DispatchQueue.main.async {
                self.loadingActivity.startAnimating()
                self.downloadView.isHidden = false
                self.syncButton.isEnabled = false
                self.setProgress(percentage: String(format: "%.2f", (progress.fractionTransferred*100)))
            }
            
            if (progress.isTransferComplete) {
                self.setupUI()
                self.token?.stop()
            }
        }
    }
    
    @IBAction func sync(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Warning", message: "Finished downloading images!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        loadingActivity.startAnimating()
        downloadView.isHidden = false
        syncButton.isEnabled = false
//        ApplicationUtilities.downloadImages() {
//            self.loadingActivity.stopAnimating()
//            self.downloadView.isHidden = true
//            self.present(alert, animated: true)
//            self.syncButton.isEnabled = true
//        }
        
        ApplicationUtilities.downloadImages(completionHandler: setupUI, imageProgress: setProgress)

    }
    
    func setProgress(percentage: String) {
        downloadLabel.text = "Downloading \(percentage)%"
    }
    
    func setupUI() {
        self.loadingActivity.stopAnimating()
        self.downloadView.isHidden = true
        self.syncButton.isEnabled = true
    }
}
