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
import Alamofire

class ServerUtilities {
    
    static var syncUser: SyncUser? = nil
    static var customerImagesURL: String = ""
    static var optoIP: String = "101.187.132.13:8000"
    static var realmIP: String = "199.229.252.219:9080"
    static var realmURL: String = "realm://199.229.252.219:9080/~/diecast"
    static var realm: Realm? = nil
    static var realmUsername = "test@opto.com"
    static var realmPassword = "1234"
    static var defaultDiscount: Double = 0.0
    static var defaultTax = 2
    static var realmConfiguration: Realm.Configuration? = nil
    static var deduplicationNotificationToken: NotificationToken!
    static var token: SyncSession.ProgressNotificationToken?
    
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
    
    class func notificationDownload() {
        let session = SyncUser.current?.allSessions()[0]
        self.token = session?.addProgressNotification(for: .download, mode: .reportIndefinitely) {
            progress in
            print("Downloading \(progress.fractionTransferred)")
            if (progress.isTransferComplete) {
                print("Complete")
            }
        }

    }
    
    /// Login to Realm
    ///
    /// - parameter username:          Realm username
    /// - parameter password:          Realm password
    /// - parameter action:            Login actions
    /// - parameter completionHandler: callback function
    class func login(username: String, password: String, register: Bool, dispatch: DispatchGroup) {
        let serverURL = URL(string: "http://\(realmIP)")!
        let credential = SyncCredentials.usernamePassword(username: username, password: password, register: register)
        dispatch.enter()
        if (isConnectedToNetwork() && SyncUser.current == nil) {
            SyncUser.logIn(with: credential, server: serverURL as URL) { user, error in
                if let user = user {
                    syncUser = user
                    setupRealm(syncUser: user)
                } else if error != nil {
                    print(error)
                }
                dispatch.leave()
            }
        } else {
            setupRealm(syncUser: (SyncUser.current)!)
            dispatch.leave()
        }
    }
    
    class func setupRealmWhenHaveInternet() {
        
    }
    
    class func setDefaultRealmConfigurationWithUser(user: SyncUser, serverURL: URL) {
        realmConfiguration = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: serverURL))
    }
    
    class func logout() {
        if (syncUser != nil) {
            syncUser?.logOut()
        }
    }
    
    class func logoutAll() {
        for person in SyncUser.all {
            person.value.logOut()
        }
    }
    
    class func setupRealm(syncUser: SyncUser) {
        self.syncUser = syncUser
        let syncServerURL = URL(string: "realm://\(realmIP)/~/diecast")!
        setDefaultRealmConfigurationWithUser(user: syncUser, serverURL: syncServerURL)
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
    
    class func getOPTOUSer() -> [OPTOUser]{
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(OPTOUser.self) {
                return Array(list)
            }
            return [OPTOUser]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(OPTOUser.self)
            return Array(list)
        }
    }
    
    class func getOPTOUSer(predicate: NSPredicate) -> [OPTOUser]{
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(OPTOUser.self).filter(predicate) {
                return Array(list)
            }
            return [OPTOUser]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(OPTOUser.self).filter(predicate)
            return Array(list)
        }
    }
    
    class func loginLocal(employee: String, password: String) -> Bool{
        let predicate = NSPredicate(format: "employee = %@ AND password = %@", employee, password)
        if (realm != nil && !(realm?.isEmpty)!) {
            let user = ServerUtilities.realm?.objects(OPTOUser.self).filter(predicate)
            if ((user?.count)! > 0) {
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
                //print(list.count)
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
            let predicate = NSPredicate(format: "groupCode = %@ AND stock > 0", group)
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
            let predicate = NSPredicate(format: "subGroupCode = %@ AND stock > 0", group)
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
    
    class func updateStockMaterial(partCode: String, stock: Double) -> Int{
        let predicate = NSPredicate(format: "code = %@", partCode)
        let material = getMaterial(predicate: predicate).first
        let stock = (material?.stock)! + stock
        if (stock >= 0) {
            try! realm?.write {
                let stock = (material?.stock)! + stock
                material?.stock = stock
            }
        }
        return Int(stock)
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
    
    /// Get Contact
    class func getContact(predicate: NSPredicate) -> [Contact] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Contact.self).filter(predicate) {
                return Array(list)
            }
            return [Contact]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Contact.self).filter(predicate)
            return Array(list)
        }
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
    
    class func getContactSorted(predicate: NSPredicate) -> [Contact] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Contact.self).filter(predicate).sorted(byProperty: "name") {
                return Array(list)
            }
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Contact.self).filter(predicate).sorted(byProperty: "name")
            return Array(list)
        }
        return [Contact]()
    }
    
    class func addContact(contact: Contact) {
        if (realm != nil || isConnectedToNetwork()) {
            try! realm?.write {
                realm?.add(contact, update: true)
            }
        } else {
            let _realm = try! Realm()
            try! _realm.write {
                _realm.add(contact, update: true)
            }
        }
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
    
    class func sendPendingOrder(input: PendingOrder, completionHandler: @escaping ()->()) {
        let myNSURL = URL(string: "http://\(optoIP)" + "/api/salesorder/\(input.code)")
        var myRequest = URLRequest(url: myNSURL!)
        myRequest.httpMethod = "POST"
        let loginString =  NSString(format: "%@:%@", "OPTO", "opto")
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        myRequest.httpBody = try! input.getJSON().rawData()
        myRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        Alamofire.request(myRequest).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let _input = PendingOrder(value: input)
                _input.opto_rcd = json["code"].string!
                _input.opto_rcd_timestamp = String(describing: NSDate())
                addPendingOrder(input: _input)
            }
            completionHandler()
        }
    }
    
    class func deleteOrder(pending: PendingOrder) {
        if (realm != nil || isConnectedToNetwork()) {
            try! realm?.write {
                realm?.delete(pending)
            }
        } else {
            let _realm = try! Realm()
            try! _realm.write {
                _realm.delete(pending)
            }
        }
    }
    
    class func deleteItem(inPendingOrder: PendingOrder, partcode: String) {
        
        var partlist = ApplicationUtilities.splitString(input: inPendingOrder.part_code)
        var duedate = ApplicationUtilities.splitString(input: inPendingOrder.due_date_1)
        var unitprice = ApplicationUtilities.splitString(input: inPendingOrder.total_amount_one)
        var quantity = ApplicationUtilities.splitString(input: inPendingOrder.total_qty)
        var tax = ApplicationUtilities.splitString(input: inPendingOrder.tax_pro)
        var discount = ApplicationUtilities.splitString(input: inPendingOrder.ma)
        var total = ApplicationUtilities.splitString(input: inPendingOrder.sum_one)
        
        let index = partlist.index(of: partcode)
        partlist.remove(at: index!)
        duedate.remove(at: index!)
        unitprice.remove(at: index!)
        quantity.remove(at: index!)
        tax.remove(at: index!)
        discount.remove(at: index!)
        total.remove(at: index!)
        
        let parts = ApplicationUtilities.appendArray(input: partlist)
        let date = ApplicationUtilities.appendArray(input: duedate)
        let price = ApplicationUtilities.appendArray(input: unitprice)
        let qty = ApplicationUtilities.appendArray(input: quantity)
        let taxes = ApplicationUtilities.appendArray(input: tax)
        let dis = ApplicationUtilities.appendArray(input: discount)
        let tot = ApplicationUtilities.appendArray(input: total)
        
        inPendingOrder.part_code = parts
        inPendingOrder.due_date_1 = date
        inPendingOrder.total_amount_one = price
        inPendingOrder.total_qty = qty
        inPendingOrder.tax_pro = taxes
        inPendingOrder.ma = dis
        inPendingOrder.sum_one = tot
        inPendingOrder.partList.remove(at: index!)
        
        if (realm != nil || isConnectedToNetwork()) {
            try! realm?.write {
                realm?.add(inPendingOrder, update: true)
            }
        } else {
            let _realm = try! Realm()
            try! _realm.write {
                _realm.add(inPendingOrder, update: true)
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
    
    class func addFavourite(input: Material) {
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
    
    /// Get Favourite
    class func getFavourite() -> [Favourite] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Favourite.self) {
                return Array(list)
            }
            return [Favourite]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Favourite.self)
            return Array(list)
        }
    }
    
    class func getFavourite(predicate: NSPredicate) -> [Favourite] {
        if (realm != nil || isConnectedToNetwork()) {
            if let list = realm?.objects(Favourite.self).filter(predicate) {
                return Array(list)
            }
            return [Favourite]()
        } else {
            let _realm = try! Realm()
            let list = _realm.objects(Favourite.self).filter(predicate)
            return Array(list)
        }
    }
    
    /// Save Favourite
    class func saveFavourite(input: Favourite) {
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
}
