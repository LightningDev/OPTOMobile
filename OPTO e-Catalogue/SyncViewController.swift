//
//  SyncViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 6/3/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SyncViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var optoUser = [Material]()
    let session = SyncUser.current!.allSessions()[0]
    var token: SyncSession.ProgressNotificationToken?
    var counter:Float = 0 {
        didSet {
            setupUI(counter: counter)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //optoUser = ServerUtilities.getMaterial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.load()
        }
    }
    
    @IBAction func get(sender: UIButton) {
        let predicate = NSPredicate(format: "stock > 0")
        optoUser = ServerUtilities.getMaterial(predicate: predicate)
        //let numberOfItems = optoUser.count
        //print(numberOfItems)
        load()
    }
    
    func load() {
        self.token = session.addProgressNotification(for: .download, mode: .reportIndefinitely) {
            progress in
            DispatchQueue.main.async {
                self.counter = Float(progress.fractionTransferred)
                return
            }
//            print(progress.fractionTransferred)
            //print(progress.transferrableBytes)
            //self.setProgress(percentage: String(format: "%.2f", (progress.fractionTransferred*100)))
            if (progress.isTransferComplete) {
                self.token?.stop()
                self.performSegue(withIdentifier: "segueToLogin", sender: self)
            }
        }
    }
    
    func setupUI(counter: Float) {
        let fractionalProgress = counter
        let animated = counter != 0
        //print(fractionalProgress)
        self.progressView.setProgress(fractionalProgress, animated: animated)
        self.progressLabel.text = String(format: "%.2f", fractionalProgress*100) + " %"
    }
    
}
