//
//  SyncOPTO.swift
//  OPTOServer
//
//  Created by Nhat Tran on 7/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class SyncOPTO {
    
    var config: Realm.Configuration? = nil
    var realmUser: SyncUser? = nil
    var username: String = ""
    var password: String = ""
    var serverIP: String = ""
    var realm: Realm? = nil
    var trackingOrder = [String]()
    
    init(user: SyncUser, url: String) {
        realmUser = user
        let _url = "\(url.replacingOccurrences(of: "http", with: "realm"))/~/diecast"
        let syncServerURL = URL(string: _url)!
        config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: syncServerURL))
        realm = try! Realm(configuration: config!)
    }
    
    func updateUser(emp: String, pass: String) {
        let user = OPTOUser()
        user.employee = emp
        user.password = pass
        try! realm?.write {
            realm?.add(user, update: true)
        }
    }
    
    func postOrder() {
        
    }
    
    func syncDatabase(completionHandler: @escaping () -> ()) {
        
        if (realm != nil) {
            if ((realm?.objects(OPTOUser.self).count)! > 0) {
                // Sync Material
                let mat = DispatchGroup()
                syncMaterial(dispatch: mat)
                mat.notify(queue: DispatchQueue.main) {
                    self.matchMaterialWithGroup()
                    completionHandler()
                }
            } else {
                // Sync Material
                let disGroup = DispatchGroup()
                syncMaterial(dispatch: disGroup)
                
                // Sync Group
                syncGroup(dispatch: disGroup)
                
                // Sync Contact
                syncContact(dispatch: disGroup)
                
                // Sync Employee
                syncEmployee(dispatch: disGroup)
                
                disGroup.notify(queue: DispatchQueue.main) {
                    self.matchMaterialWithGroup()
                    completionHandler()
                }
            }
        }
    }
    
    func dispatch_semaphore() {
        
    }
    
    func syncEmployee(dispatch: DispatchGroup) {
        let endpoint = serverIP + "/api/employee"
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        dispatch.enter()
        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let url = json["employees"]
                
                for i in 0..<url.count {
                    let employee = Employee()
                    let item = url[i]
                    employee.code = String(describing: item["code"].rawValue)
                    employee.name = String(describing: item["name"].rawValue)
                    try! self.realm?.write {
                        self.realm?.add(employee, update: true)
                    }
                }
            }
            dispatch.leave()
        }
    }
    
    
    func testDatabase() -> [Int]{
        let employee = realm?.objects(Employee.self).count
        let material = realm?.objects(Material.self).count
        return [employee!, material!]
    }
    
    
    func addMaterial(material: Material) {
        if (realm != nil) {
            try! realm?.write {
                realm?.add(material, update: true)
            }
        }
    }
    
    func addContact(contact: Contact) {
        if (realm != nil) {
            try! realm?.write {
                realm?.add(contact, update: true)
            }
        }
    }
    
    func syncMaterial(dispatch: DispatchGroup) {
        let endpoint = serverIP + "/api/catalogue"
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        dispatch.enter()
        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let list = json["items"]
                try! self.realm?.write {
                    for i in 0..<(list.count) {
                        let material = Material()
                        let item = list[i].dictionary!
                        
                        if (item["description"] != nil) {
                            let desc = String(describing: list[i]["description"].rawValue)
                            material.desc = desc
                        }
                        
                        if (item["employee"] != nil) {
                            let emp = String(describing: list[i]["employee"].rawValue)
                            material.employee = emp
                        }
                        
                        if (item["part_group"] != nil) {
                            let part_group = String(describing: list[i]["part_group"].rawValue)
                            material.groupCode = part_group
                        }
                        
                        if (item["material_group_sub"] != nil) {
                            let material_group_sub = String(describing: list[i]["material_group_sub"].rawValue)
                            material.subGroupCode = material_group_sub
                        }
                        
                        if (item["path"] != nil) {
                            let path = String(describing: list[i]["path"].rawValue)
                            material.path = path
                        }
                        
                        if (item["stock"] != nil) {
                            var stock = String(describing: list[i]["stock"].rawValue)
                            if (stock.indexOfCharacter(char: ".") == 0) {
                                stock = "0\(stock)"
                            }
                            material.stock = Double(stock)!
                        }
                        
                        if (item["cash_p_m"] != nil) {
                            var cash_p_m = String(describing: list[i]["cash_p_m"].rawValue)
                            if (cash_p_m.indexOfCharacter(char: ".") == 0 ) {
                                cash_p_m = "0\(cash_p_m)"
                            }
                            material.cash_p_m = Double(cash_p_m)!
                        }
                        
                        if (item["barcode"] != nil) {
                            var barcode = String(describing: list[i]["barcode"].rawValue)
                            material.barcode = barcode
                        }
                        
                        if (item["material_code"] != nil) {
                            let code = String(describing: list[i]["material_code"].rawValue)
                            material.code = code
                            //print("Catalogue \(code)")
                            self.realm?.add(material, update: true)
                        }
                        
                    }
                }
                //print(self.realm?.objects(Material.self).count)
                dispatch.leave()
            }
        }
    }
    
    func syncContact(dispatch: DispatchGroup) {
        let endpoint = serverIP + "/api/clients"
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        dispatch.enter()
        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let url = json["_embedded"]["item"]
                
                for i in 0..<url.count {
                    let contact = Contact()
                    let item = url[i]
                    //print("Contact \(item["client_code"].rawValue)")
                    contact.code = String(describing: item["client_code"].rawValue)
                    contact.name = String(describing: item["client_name"].rawValue)
                    contact.employee = String(describing: item["info"].rawValue)
                    // Postal
                    contact.postal_city = String(describing: item["city"].rawValue)
                    contact.postal_address_1 = String(describing: item["address1"].rawValue)
                    contact.postal_address_2 = String(describing: item["address2"].rawValue)
                    contact.postal_country = String(describing: item["country_code"].rawValue)
                    contact.postal_postcode = String(describing: item["postcode"].rawValue)
                    contact.postal_state = String(describing: item["state"].rawValue)
                    // Delivery
                    contact.delivery_city = String(describing: item["postal_city"].rawValue)
                    contact.delivery_address_1 = String(describing: item["postal_address1"].rawValue)
                    contact.delivery_address_2 = String(describing: item["postal_address2"].rawValue)
                    contact.delivery_postcode = String(describing: item["postal_postcode"].rawValue)
                    contact.delivery_state = String(describing: item["p_state"].rawValue)
                    //Discount
                    contact.discount_1 = String(describing: item["discount"].rawValue)
                    contact.discount_2 = String(describing: item["discount_1"].rawValue)
                    contact.discount_early = String(describing: item["discount_2"].rawValue)
                    
                    
                    contact.email = String(describing: item["e_mail"].rawValue)
                    contact.website = String(describing: item["web_site"].rawValue)
                    contact.phone = String(describing: item["phone_2"].rawValue)
                    try! self.realm?.write {
                        self.realm?.add(contact, update: true)
                    }
                }
            }
            dispatch.leave()
        }
    }
    
    func syncGroup(dispatch: DispatchGroup) {
        let endpoint = serverIP + "/api/catalogue?count=1"
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        dispatch.enter()
        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let group_code = json["group_code"]
                let sub_group_code = json["sub_group_code"]
                
                try! self.realm?.write {
                    for i in 0..<(group_code.count) {
                        let code = String(describing: group_code[i]["code"].rawValue)
                        let desc = String(describing: group_code[i]["desc"].rawValue)
                        let materialGroup = Group()
                        materialGroup.code = code
                        materialGroup.desc = desc
                        materialGroup.type = GroupType.MAIN_GROUP.rawValue
                        self.realm?.add(materialGroup, update: true)
                    }
                    
                    for i in 0..<sub_group_code.count {
                        let code = String(describing: sub_group_code[i]["code"].rawValue)
                        let desc = String(describing: sub_group_code[i]["desc"].rawValue)
                        let materialGroup = Group()
                        materialGroup.code = code
                        materialGroup.desc = desc
                        materialGroup.type = GroupType.SUB_GROUP.rawValue
                        self.realm?.add(materialGroup, update: true)
                    }
                }
            }
            dispatch.leave()
        }
    }
    
    func syncSalesOrder(dispatch: DispatchGroup) {
        
        let endpoint = serverIP + "/api/salesorder?part=1"
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        dispatch.enter()
        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            if (response.result.isSuccess) {
                let json = JSON(data: response.data!)
                let list = json["items"]
                try! self.realm?.write {
                    for i in 0..<list.count {
                        let items = list[i]
                        let customer = String(describing: items["customer"].rawValue)
                        let order_no = String(describing: items["order_no"].rawValue)
                        
                        let part_code_one = items["part_code_one"].string
                        let total_qty = items["total_qty"].string
                        let total_amount_one = items["total_amount_one"].string
                        let ma = items["ma"].string
                        let sum_one = items["sum_one"].string
                        let due_date_1 = items["due_date_1"].string
                        let tax_pro = items["tax_pro"].string
                        
                        let order = SalesOrder()
                        order.part_code = part_code_one!
                        order.total_qty = total_qty!
                        order.total_amount_one = total_amount_one!
                        order.ma = ma!
                        order.sum_one = sum_one!
                        order.due_date_1 = due_date_1!
                        order.tax_pro = tax_pro!
                        order.customer = customer
                        order.code = order_no
                        self.realm?.add(order, update: true)
                    }
                }
            }
            dispatch.leave()
        }
    }
    
    func syncPendingOrder(dispatch: DispatchGroup) {
        let result = realm?.objects(PendingOrder.self)
        let orders = Array(result!)
        let cnt = orders.count
        
        for i in 0..<cnt {
            if (orders[i].send && !trackingOrder.contains(orders[i].code) && orders[i].opto_rcd == "") {
                dispatch.enter()
                trackingOrder.append(orders[i].code)
                sendPendingOrder(input: orders[i]) {
                    dispatch.leave()
                }
            }
        }
    }
    
    func sendPendingOrder(input: PendingOrder, completionHandler: @escaping ()->()) {
        let myNSURL = URL(string: "http://101.187.132.13:8000/api/salesorder/\(input.code)")
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
                self.addPendingOrder(input: _input)
            }
            self.trackingOrder.remove(at: self.trackingOrder.index(of: input.code)!)
            completionHandler()
        }
    }
    
    func addPendingOrder(input: PendingOrder) {
        if (realm != nil) {
            try! realm?.write {
                realm?.add(input, update: true)
            }
        }
    }
    
    func matchMaterialWithGroup() {
        let results = realm?.objects(Material.self)
        let _results = realm?.objects(Group.self)
        let materials = Array(results!)
        let groups = Array(_results!)
        var dict = Dictionary<String, Group>()
        for i in 0..<groups.count {
            let newGroup = Group(value: groups[i])
            dict["\(groups[i].code)"] = newGroup
        }
        for i in 0..<materials.count {
            let groupcode = materials[i].groupCode
            let subgroupcode = materials[i].subGroupCode
            if (groupcode != nil) {
                dict[groupcode!]?.items.append(materials[i])
                //print("Match \(groupcode!) with \(materials[i].code)")
            }
            if (subgroupcode != nil) {
                dict[subgroupcode!]?.items.append(materials[i])
                //print("Match \(subgroupcode!) with \(materials[i].code)")
            }
        }
        
        try! self.realm?.write {
            for i in 0..<groups.count {
                let grp = dict["\(groups[i].code)"]
                self.realm?.add(grp!, update: true)
                //print("Match \(groups[i].code)")
            }
        }
    }
    
    func matchMaterialWithOrder() {
        let results = realm?.objects(SalesOrder.self)
        let orders = Array(results!)
        
        try! self.realm?.write {
            for i in 0..<orders.count {
                let codeList = orders[i].part_code
                let code = codeList.characters.split{$0 == ","}.map(String.init)
                print("Match \(orders[i].code)")
                if (orders[i].code == "42922") {
                    
                }
                for j in 0..<code.count {
                    let predicate = NSPredicate(format: "code = %@", code[j])
                    let material = realm?.objects(Material.self).filter(predicate).first
                    if (material != nil) {
                        orders[i].partList.append(material!)
                    } else {
                        
                    }
                }
                self.realm?.add(orders[i], update: true)
                
            }
        }
    }
}


extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = characters.index(of: char) {
            return characters.distance(from: startIndex, to: idx)
        }
        return nil
    }
}
