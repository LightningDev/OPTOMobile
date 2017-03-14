//
//  ApplicationUtilities.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 16/11/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import ZipArchive

class ApplicationUtilities {
    static var CurrentGroup = GroupType.NONE
    static var DefaultUser = ""
    static var loginUser = ""
    static var switchCustomer = false
    static var currentImage = ""
    static var currentOrder = [String:String]()
    static var _currentOrder = [String:String]()
    static var selectedCell = CatalogueCells()
    static var testing: Bool {
        if (ApplicationUtilities.loginUser != "test") {
            return false
        } else {
            return true
        }
    }
    
    class func splitString(input: String) -> [String]{
        return input.characters.split{$0 == ","}.map(String.init)
    }
    
    class func appendArray(input: [String]) -> String {
        return input.joined(separator: ",")
    }
    
    class func updatePrice() -> Double{
        var sum = 0.0
        for (code,qty) in currentOrder {
            let price = Double(_currentOrder[code]!)
            let qty = Double(qty)
            sum += (price!*qty!)
        }
        return sum
    }
    
    class func resetOrder() {
        currentOrder.removeAll()
        _currentOrder.removeAll()
    }
    
    class func checkComma(input: String) -> String {
        let index = input.index(input.startIndex, offsetBy: 0)
        if (input[index] == ",") {
            var str = String(input)
            str?.remove(at: index)
            return str!
        }
        return input
    }
    
    class func randomString(length: Int) -> String {
        
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    class func createDirectory(name: String) {
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let logsPath = documentsPath.appendingPathComponent(name)
        if (FileManager.default.fileExists(atPath: logsPath.path)) {
            return
        }
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    class func saveImage(name: String) {
        createDirectory(name: "OPTOImages")
        //let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("images.zip")
        let destination = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("OPTOImages")
        
        SSZipArchive.unzipFile(atPath: "\(paths)", toDestination: "\(destination)")
    }
    
    class func downloadImages(completionHandler: @escaping ()->(), imageProgress: @escaping (String) -> ()) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download("\(ServerUtilities.customerImagesURL)/images.zip", to: destination).downloadProgress{ progress in
            //print("Download Progress: \(progress.fractionCompleted)")
            imageProgress(String(format: "%.2f", (progress.fractionCompleted*100)))
        }.response() { response in
            saveImage(name: "")
            completionHandler()
        }
    }
    
    class func createOrder() -> String {
        let styler = DateFormatter()
        styler.dateFormat = "dd/MM/yyyy"
        let date = styler.string(from: NSDate() as Date)
        let predicate = NSPredicate(format: "customer = %@", ApplicationUtilities.DefaultUser)
        let order = ServerUtilities.getPendingOrder(predicate: predicate).first
        var newOrder: PendingOrder? = nil
        
        if (order != nil && !(order?.send)!) {
            newOrder = PendingOrder(value: order!)
        } else {
            let newCode = "\(ApplicationUtilities.DefaultUser)-\(randomString(length: 4))"
            newOrder = PendingOrder()
            newOrder?.code = String(newCode)
            newOrder?.customer = ApplicationUtilities.DefaultUser
            newOrder?.employee = ApplicationUtilities.loginUser
        }
        if (ApplicationUtilities.DefaultUser != "") {
            
            for (code, qty) in ApplicationUtilities.currentOrder {
                let matcondition = NSPredicate(format: "code = %@", code)
                let result = ServerUtilities.getMaterial(predicate: matcondition).first
                let material = Material(value: result!)
                
                newOrder?.part_code = (newOrder?.part_code)! + ",\(code)"
                newOrder?.due_date_1 = (newOrder?.due_date_1)! + ",\(date)"
                newOrder?.sum_one = (newOrder?.sum_one)! + ",\((Double(material.cash_p_m) * Double(qty)! * (100 - ServerUtilities.defaultDiscount)) / 100)"
                newOrder?.tax_pro = (newOrder?.tax_pro)! + ",\(ServerUtilities.defaultTax)"
                newOrder?.total_amount_one = (newOrder?.total_amount_one)! + ",\(material.cash_p_m)"
                newOrder?.total_qty = (newOrder?.total_qty)! +
                ",\(qty)"
                newOrder?.ma = (newOrder?.ma)! + ",\(ServerUtilities.defaultDiscount)"
                
                material.stock = Double(material.stock) - Double(qty)!
                newOrder?.partList.append(material)
            }
            newOrder?.part_code = checkComma(input: (newOrder?.part_code)!)
            newOrder?.due_date_1 = checkComma(input: (newOrder?.due_date_1)!)
            newOrder?.sum_one = checkComma(input: (newOrder?.sum_one)!)
            newOrder?.tax_pro = checkComma(input: (newOrder?.tax_pro)!)
            newOrder?.total_amount_one = checkComma(input: (newOrder?.total_amount_one)!)
            newOrder?.total_qty = checkComma(input: (newOrder?.total_qty)!)
            newOrder?.ma = checkComma(input: (newOrder?.ma)!)
            ServerUtilities.addPendingOrder(input: newOrder!)
            resetOrder()
        } else {
            
        }
        
        return (newOrder?.code)!
    }
}
