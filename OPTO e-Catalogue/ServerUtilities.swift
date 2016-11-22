//
//  ServerUtilities.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 8/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import Foundation
import RealmSwift
import SystemConfiguration

class ServerUtilities {
    
    static var syncUser: SyncUser? = nil
    static var realmIP: String = "http://192.168.222.113:9080"
    static var realmURL: String = "realm://192.168.222.113:9080/~/OPTO"
    static var realm: Realm? = nil
    static var realmUsername = "admin@opto.com"
    static var realmPassword = "opto"
    static var defaultDiscount: Double = 0.0
    static var defaultTax = 2
    
    /// Internet connection status
    ///
    /// - returns: true if connected, otherwise false if no connection
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
    
    /// Login to Realm
    ///
    /// - parameter username:          Realm username
    /// - parameter password:          Realm password
    /// - parameter action:            Login actions
    /// - parameter completionHandler: callback function
    class func login(username: String, password: String, action: AuthenticationActions, completionHandler: @escaping ()->()) {
        let serverURL = NSURL(string: realmIP)!
        let credential = Credential.usernamePassword(username: username, password: password, actions: [action])
        SyncUser.authenticate(with: credential, server: serverURL as URL) { user, error in
            if let user = user {
                syncUser = user
                let syncServerURL = URL(string: realmURL)!
                let config = Realm.Configuration(syncConfiguration: (user, syncServerURL))
                realm = try! Realm(configuration: config)
            } else if error != nil {
                
            }
            completionHandler()
        }
    }
    
    class func loginOffline(username: String, password: String) -> Bool{
        //        let user = ServerUtilities.getOfflineUser(username: username, password: password)
        //        if (user.username != "") {
        //            realm = try! Realm()
        //            return true
        //        }
        return false
    }
    
    class func saveUser(user: OPTOUser) {
        let _realm = try! Realm()
        try! _realm.write {
            _realm.add(user, update: true)
        }
    }
    
    class func syncOPTOUser() {
        if (realm != nil) {
            let results = realm?.objects(OPTOUser.self)
            let users = Array(results!)
            let _realm = try! Realm()
            try! _realm.write {
                for i in 0..<users.count {
                    let newUser = OPTOUser(value: users[i])
                    _realm.add(newUser, update: true)
                }
            }
        }
    }
    
    class func loginLocal(employee: String, password: String) -> Bool{
        let predicate = NSPredicate(format: "employee = %@ AND password = %@", employee, password)
        if (realm != nil || isConnectedToNetwork()) {
            let user = realm?.objects(OPTOUser.self).filter(predicate)
            if ((user?.count)! > 0) {
                return true
            }
        } else {
            let _realm = try! Realm()
            let user = _realm.objects(OPTOUser.self).filter(predicate)
            if (user.count > 0) {
                return true
            }
        }
        return false
    }
    
    /// Get Material
    class func getMaterial() -> [Material] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Material.self) {
                return Array(list)
            }
            return [Material]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Material.self)
            return Array(list)
        }
    }
    
    /// Get Material
    class func getMaterial(predicate: NSPredicate) -> [Material] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Material.self).filter(predicate) {
                return Array(list)
            }
            return [Material]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Material.self).filter(predicate)
            return Array(list)
        }
    }
    
    
    /// Get Material
    class func getMaterial(group: String, type: GroupType) -> [Material] {
        switch (type) {
        case .MAIN_GROUP:
            let predicate = NSPredicate(format: "groupCode = %@", group)
            if (realm != nil || isConnectedToNetwork()) {
                if let list = realm?.objects(Material.self).filter(predicate) {
                    return Array(list)
                }
            } else {
                let _realm = try! Realm()
                let list = _realm.objects(Material.self).filter(predicate)
                return Array(list)
            }
        case .SUB_GROUP:
            let predicate = NSPredicate(format: "subGroupCode = %@", group)
            if (realm != nil || isConnectedToNetwork()) {
                if let list = realm?.objects(Material.self).filter(predicate) {
                    return Array(list)
                }
            } else {
                let _realm = try! Realm()
                let list = _realm.objects(Material.self).filter(predicate)
                return Array(list)
            }
        default:
            if (realm != nil || isConnectedToNetwork()) {
                if let list = realm?.objects(Material.self) {
                    return Array(list)
                }
            } else {
                let _realm = try! Realm()
                let list = _realm.objects(Material.self)
                return Array(list)
            }
        }
        return [Material]()
    }
    
    class func addMaterial(material: Material) {
        if (realm != nil || isConnectedToNetwork()) {
            try! realm?.write {
                realm?.add(material, update: true)
            }
        } else {
            let _realm = try! Realm()
            try! _realm.write {
                _realm.add(material, update: true)
            }
        }
    }
    
    /// Sync Material
    ///
    /// - parameter group: list Material
    class func syncMaterial(material: [Material]) {
        let _realm = try! Realm()
        let cnt = material.count
        try! _realm.write {
            for i in 0..<cnt {
                let newMaterial = copyMaterial(material: material[i])
                _realm.add(newMaterial, update: true)
            }
        }
    }
    
    /// Copy managed object
    ///
    /// - parameter group: Material
    ///
    /// - returns: copied Material
    class func copyMaterial(material: Material) -> Material {
        let newMaterial = Material(value: material)
        return newMaterial
    }
    
    /// Get Group
    class func getGroup() -> [Group] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Group.self) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Group.self)
            return Array(list)
        }
        return [Group]()
    }
    
    class func getGroup(type: GroupType) -> [Group] {
        let predicate = NSPredicate(format: "type = %@", type.rawValue)
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Group.self).filter(predicate) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Group.self).filter(predicate)
            return Array(list)
        }
        return [Group]()
    }
    
    /// Sync Group
    ///
    /// - parameter group: list group
    class func syncGroup(group: [Group]) {
        let _realm = try! Realm()
        let cnt = group.count
        try! _realm.write {
            for i in 0..<cnt {
                let newGroup = copyGroup(group: group[i])
                _realm.add(newGroup, update: true)
            }
        }
    }
    
    /// Copy managed object
    ///
    /// - parameter group: group
    ///
    /// - returns: copied group
    class func copyGroup(group: Group) -> Group {
        let newGroup = Group(value: group)
        newGroup.items.removeAll()
        for i in 0..<group.items.count {
            newGroup.items.append(copyMaterial(material: group.items[i]))
        }
        return newGroup
    }
    
    /// Get Contact
    class func getContact() -> [Contact] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Contact.self) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Contact.self)
            return Array(list)
        }
        return [Contact]()
    }
    
    class func getContactSorted() -> [Contact] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Contact.self).sorted(byProperty: "name") {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Contact.self).sorted(byProperty: "name")
            return Array(list)
        }
        return [Contact]()
    }
    
    /// Sync Contact
    ///
    /// - parameter contact: contact
    class func syncContact(contact: [Contact]) {
        let _realm = try! Realm()
        let cnt = contact.count
        try! _realm.write {
            for i in 0..<cnt {
                let newContact = copyContact(contact: contact[i])
                _realm.add(newContact, update: true)
            }
        }
    }
    
    /// Copy managed object
    ///
    /// - parameter contact: contact
    ///
    /// - returns: new contact
    class func copyContact(contact: Contact) -> Contact {
        let newContact = Contact(value: contact)
        return newContact
    }
    
    /// Get Order
    class func getOrder() -> [SalesOrder] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(SalesOrder.self) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(SalesOrder.self)
            return Array(list)
        }
        return [SalesOrder]()
    }
    
    class func getOrderSorted(ascending: Bool) -> [SalesOrder] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(SalesOrder.self) {
                return Array(list.sorted(byProperty: "code", ascending: ascending))
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(SalesOrder.self)
            return Array(list.sorted(byProperty: "code", ascending: ascending))
        }
        return [SalesOrder]()
    }
    
    /// Get Pending Order
    class func getPendingOrder() -> [PendingOrder] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(PendingOrder.self) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(PendingOrder.self)
            return Array(list)
        }
        return [PendingOrder]()
    }
    
    class func getPendingOrder(predicate: NSPredicate) -> [PendingOrder] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(PendingOrder.self).filter(predicate) {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(PendingOrder.self).filter(predicate)
            return Array(list)
        }
        return [PendingOrder]()
    }

    class func getPendingOrderSorted(ascending: Bool) -> [PendingOrder] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(PendingOrder.self) {
                return Array(list.sorted(byProperty: "code", ascending: ascending))
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(PendingOrder.self)
            return Array(list.sorted(byProperty: "code", ascending: ascending))
        }
        return [PendingOrder]()
    }
    
    class func addPendingOrder(input: PendingOrder) {
        if (realm != nil || isConnectedToNetwork()) {
            try! realm?.write {
                realm?.add(input, update: true)
            }
        } else {
            let _realm = try! Realm()
            try! _realm.write {
                _realm.add(input, update: true)
            }
        }
    }
    
    /// Sync Order
    ///
    /// - parameter contact: order
    class func syncOrder(order: [SalesOrder]) {
        let _realm = try! Realm()
        let cnt = order.count
        try! _realm.write {
            for i in 0..<cnt {
                let newOrder = copyOrder(order: order[i])
                _realm.add(newOrder, update: true)
            }
        }
    }
    
    /// Copy managed object
    ///
    /// - parameter order: order
    ///
    /// - returns: new order
    class func copyOrder(order: SalesOrder) -> SalesOrder {
        let newOrder = SalesOrder(value: order)
        newOrder.partList.removeAll()
        for i in 0..<order.partList.count {
            newOrder.partList.append(copyMaterial(material: order.partList[i]))
        }
        return newOrder
    }
    
    class func getImages() {
        let material = getMaterial()
        for i in 0..<material.count {
            
        }
    }
}
