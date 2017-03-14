//
//  MainTabbarController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 5/12/16.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = tabBarController.selectedIndex
        if (index == 1) {
//            let nav = viewController as! UINavigationController
//            let destination = nav.topViewController as! CatalogueViewController
//            destination.customerButton.title = "Select Customer"
//            if (ApplicationUtilities.DefaultUser != "") {
//                destination.customerButton.title = "\(ApplicationUtilities.DefaultUser)"
//            }
        } else if (index == 2) {
//            let split = viewController as! UISplitViewController
//            let navController = split.viewControllers.first as! UINavigationController
//            let orders = navController.topViewController as? PendingOrdersViewController
//            orders?.ordersView.reloadData()
        }
    }
    
    
}
