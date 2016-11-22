//
//  Database.swift
//  OPTOServer
//
//  Created by Nhat Tran on 7/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import RealmSwift
import Foundation

enum GroupType: String {
    case MAIN_GROUP = "maingroup"
    case SUB_GROUP = "subgroup"
    case NONE = "all"
}

final class OPTOUser: Object {
    dynamic var employee = ""
    dynamic var password = ""
    
    override static func primaryKey() -> String? {
        return "employee"
    }
}

final class Employee: Object {
    dynamic var code = ""
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "code"
    }
}

final class Material: Object {
    dynamic var code = ""
    dynamic var desc: String?
    dynamic var path: String?
    dynamic var localPath: String?
    dynamic var stock: Double = 0.0
    dynamic var cash_p_m: Double = 0.0
    dynamic var groupCode: String?
    dynamic var subGroupCode: String?
    dynamic var employee = ""
    
    override static func primaryKey() -> String? {
        return "code"
    }
}

final class Contact: Object {
    dynamic var code = ""
    dynamic var name = ""
    dynamic var email = ""
    dynamic var phone = ""
    dynamic var website = ""
    dynamic var employee = ""
    
    dynamic var postal_address_1 = ""
    dynamic var postal_address_2 = ""
    dynamic var postal_city = ""
    dynamic var postal_state = ""
    dynamic var postal_postcode = ""
    dynamic var postal_country = ""
    
    dynamic var delivery_address_1 = ""
    dynamic var delivery_address_2 = ""
    dynamic var delivery_city = ""
    dynamic var delivery_state = ""
    dynamic var delivery_postcode = ""
    dynamic var delivery_country = ""
    
    override static func primaryKey() -> String? {
        return "code"
    }
}

final class SalesOrder: Object {
    dynamic var code = ""
    dynamic var part_code = ""
    dynamic var customer = ""
    dynamic var project = ""
    let partList = List<Material>()
    let aloc_type = ""  // Part Type
    dynamic var due_date_1 = "" // Due Date
    dynamic var ma = "" // Discount
    dynamic var sum_one = ""    // Total
    dynamic var tax_pro = ""    // Tax
    dynamic var to_do = ""  // Desp
    dynamic var total_amount_one = ""   // Unit price
    dynamic var total_qty = ""  // Quantity
    
    override static func primaryKey() -> String? {
        return "code"
    }
}

final class PendingOrder: Object {
    dynamic var code = ""
    dynamic var part_code = ""
    dynamic var customer = ""
    dynamic var project = ""
    let partList = List<Material>()
    let aloc_type = ""  // Part Type
    dynamic var due_date_1 = "" // Due Date
    dynamic var ma = "" // Discount
    dynamic var sum_one = ""    // Total
    dynamic var tax_pro = ""    // Tax
    dynamic var to_do = ""  // Desp
    dynamic var total_amount_one = ""   // Unit price
    dynamic var total_qty = ""  // Quantity
    dynamic var send = false
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    func getJSON() -> JSON {
        let codes = part_code.characters.split{$0 == ","}.map(String.init)
        let aloc_types = aloc_type.characters.split{$0 == ","}.map(String.init)
        let due_date_1s = due_date_1.characters.split{$0 == ","}.map(String.init)
        let mas = ma.characters.split{$0 == ","}.map(String.init)
        let sum_ones = sum_one.characters.split{$0 == ","}.map(String.init)
        let tax_pros = tax_pro.characters.split{$0 == ","}.map(String.init)
        let to_dos = to_do.characters.split{$0 == ","}.map(String.init)
        let total_amount_ones = total_amount_one.characters.split{$0 == ","}.map(String.init)
        let total_qtys = total_qty.characters.split{$0 == ","}.map(String.init)
        
        var dictionary = Dictionary<String, [String]>()
        dictionary["order_code"] = [code]
        dictionary["customer"] = [customer]
        dictionary["project"] = [project]
        dictionary["code"] = codes
        dictionary["aloc_type"] = aloc_types
        dictionary["due_date_1"] = due_date_1s
        dictionary["ma"] = mas
        dictionary["sum_one"] = sum_ones
        dictionary["tax_pros"] = tax_pros
        dictionary["to_do"] = to_dos
        dictionary["total_amount_one"] = total_amount_ones
        dictionary["total_qty"] = total_qtys
        
        let json = JSON(dictionary)
        
        return json
    }
}

final class Group: Object {
    dynamic var desc = ""
    dynamic var code = ""
    dynamic var type = ""
    let items = List<Material>()
    
    override static func primaryKey() -> String? {
        return "code"
    }
}

