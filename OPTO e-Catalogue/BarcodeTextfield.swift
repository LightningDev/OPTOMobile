//
//  BarcodeTextfield.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 6/2/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit

class BarcodeTextfield: UITextField, UITextFieldDelegate {
    
    var timer: Timer? = nil
    var _delegate: POSViewControllerDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(BarcodeTextfield.getHints(timer:)),
            userInfo: ["textField": textField],
            repeats: false)
        return true
    }
    
    func getHints(timer: Timer) {
        //var userInfo = timer.userInfo as! [String: UITextField]
        //print("Hints for textField: \(userInfo["textField"])")
        if (_delegate !=  nil) {
            //_delegate?.posViewController(enabledField: false)
            _delegate?.posViewController(typingBarcode: self.text!)
            //_delegate?.posViewController(enabledField: true)
            self.text = ""
        }
    }
}
