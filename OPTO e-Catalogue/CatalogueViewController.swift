//
//  CatalogueViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 14/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit

protocol CatalogueViewControllerDelegate {
    func setCollectionViewController(controller: GroupPopOverController, index: Int)
}

class CatalogueViewController: UIViewController {
    
    @IBOutlet weak var catalogueView: UICollectionView!
    @IBOutlet weak var groupOptions: UISegmentedControl!
    @IBOutlet weak var groupButton: UIBarButtonItem!
    
    var numberOfItems = 0
    var materials = [Material]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        catalogueView.delegate = self
        catalogueView.dataSource = self
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender:UISegmentedControl)
    {
        materials.removeAll()
        numberOfItems = 0
        catalogueView.reloadData()
        switch groupOptions.selectedSegmentIndex
        {
        case 1:
            ApplicationUtilities.CurrentGroup = .MAIN_GROUP
            groupButton.isEnabled = true
        case 2:
            ApplicationUtilities.CurrentGroup = .SUB_GROUP
            groupButton.isEnabled = true
        default:
            ApplicationUtilities.CurrentGroup = .NONE
            groupButton.isEnabled = false
            load()
        }
        
    }
    
    @IBAction func refresh() {
        load()
    }
    
    @IBAction func loadGroup() {
        
    }
    
    @IBAction func loadSubGroup() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToGroup") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! GroupPopOverController
            topView._delegate = self
        }
    }
    
    func load() {
        let predicate = NSPredicate(format: "stock > 0")
        materials = ServerUtilities.getMaterial(predicate: predicate)
        numberOfItems = materials.count
        catalogueView.reloadData()
    }
    
    func load(code: String, type: GroupType) {
        materials = ServerUtilities.getMaterial(group: code, type: type)
        numberOfItems = materials.count
        catalogueView.reloadData()
    }
}

extension CatalogueViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        return CGSize(width: width / 3, height: height / 2)
    }
}

extension CatalogueViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catalogueCells", for: indexPath) as! CatalogueCells
        cell.codeLabel.text = materials[indexPath.row].code
        cell.descLabel.text = materials[indexPath.row].desc
        cell.priceLabel.text = String(materials[indexPath.row].cash_p_m)
        
        let stock = materials[indexPath.row].stock
        cell.stockQty.text = String(stock)
        if (stock > 0) {
            cell.stockQty.textColor = UIColor.green
        } else {
            cell.stockQty.textColor = UIColor.red
        }
      
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension CatalogueViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension CatalogueViewController: CatalogueViewControllerDelegate {
    
    func setCollectionViewController(controller: GroupPopOverController, index: Int) {
        let code = controller.group[index].code
        switch (ApplicationUtilities.CurrentGroup) {
        case .MAIN_GROUP:
            load(code: code, type: .MAIN_GROUP)
        case .SUB_GROUP:
            load(code: code, type: .SUB_GROUP)
        default:
            load(code: code, type: .NONE)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}
