//
//  CatalogueViewController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 14/11/2016.
//  Copyright © 2016 TedBinary. All rights reserved.
//

import UIKit
import SDWebImage

protocol CatalogueViewControllerDelegate {
    func setCollectionViewController(controller: GroupPopOverController, index: Int)
}

protocol CatalogueViewCellDelegate {
    func showAlert(controller: UIAlertController)
    func updatePrice(price: Double)
    func performSegueManually(identifier: String)
    func updateCheckbox(indexCell: CatalogueCells)
    func catalogueCell(_ catalogueCell: CatalogueCells)
    func resetViewController()
    func checkOutOfStock() -> Bool
}

class CatalogueViewController: UIViewController {
    
    @IBOutlet weak var catalogueView: UICollectionView!
    @IBOutlet weak var groupOptions: UISegmentedControl!
    @IBOutlet weak var groupButton: UIBarButtonItem!
    @IBOutlet weak var customerButton: UIBarButtonItem!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    
    var searchBars:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width:250, height: 20))
    var numberOfItems = 0
    var materials = [Material]()
    var filterIndexes = [Int]()
    var selectedCell = CatalogueCells()
    var editMode: Bool = false
    var trackingFavourites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        catalogueView.delegate = self
        catalogueView.dataSource = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customerButton.title = "Customer"
        if (ApplicationUtilities.DefaultUser != "") {
            customerButton.title = "\(ApplicationUtilities.DefaultUser)"
        }
        
        if (filterIndexes.count == 0) {
            load()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender:UISegmentedControl)
    {
        filterIndexes.removeAll()
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
        case 3:
            ApplicationUtilities.CurrentGroup = .FAVOURITE
            groupButton.isEnabled = true
        default:
            ApplicationUtilities.CurrentGroup = .NONE
            groupButton.isEnabled = false
            load()
        }
        
    }
    
    @IBAction func edit(sender: UIBarButtonItem) {
        editMode = !editMode
        
        addToFavouriteButton.isHidden = !editMode
        catalogueView.reloadData()
    }
    
    @IBAction func unwindToCatalogue(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func outOfStockButton(sender: UIBarButtonItem) {
        filterIndexes.removeAll()
        materials.removeAll()
        numberOfItems = 0
        catalogueView.reloadData()
        ApplicationUtilities.CurrentGroup = .PRE_ORDER
        groupButton.isEnabled = false
        load()
    }
    
    @IBAction func add() {
        if (ApplicationUtilities.DefaultUser != "") {
            if (ApplicationUtilities.currentOrder.isEmpty) {
                return
            }
            let code = ApplicationUtilities.createOrder()
            let alert = UIAlertController(title: "Order of customer \(customerButton.title!)", message: "Please check order \(code)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            catalogueView.reloadData()
            totalPrice.text = "0"
            ApplicationUtilities.DefaultUser = ""
            setCustomer()
        } else {
            let alert = UIAlertController(title: "Warning", message: "Please Select Customer", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reset() {
        resetView()
    }
    
    @IBAction func createFavourite() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToGroup") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! GroupPopOverController
            topView._delegate = self
        } else if (segue.identifier == "segueToCustomerList") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! CustomerPopOverController
            topView.delegate = self
            topView._delegate = self
            let topViewPop = topView.popoverPresentationController
            topViewPop?.sourceView = self.view
            topViewPop?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        } else if (segue.identifier == "segueMatdetails") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! ItemDetailsViewController
            topView._code = ApplicationUtilities.selectedCell.codeLabel.text!
            topView._desc = ApplicationUtilities.selectedCell.descLabel.text!
            topView._stock = ApplicationUtilities.selectedCell.stockQty.text!
            topView._stockfield = ApplicationUtilities.selectedCell.stockField.text!
            topView._price = ApplicationUtilities.selectedCell.priceLabel.text!
            if (ApplicationUtilities.selectedCell.myImage.image != nil) {
                topView._image = ApplicationUtilities.selectedCell.myImage.image!
            }
        } else if (segue.identifier == "favouriteList") {
            let navBar = segue.destination as? UINavigationController
            let topView = navBar?.topViewController as! FavouritePopOverController
            topView.delegate = self
            
        }
    }
    
    func create() {
        
    }
    
    func resetView() {
        let alert = UIAlertController(title: "Warning", message: "This action will reset the order", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.resetOrder()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func resetOrder() {
        ApplicationUtilities.resetOrder()
        editMode = false
        catalogueView.reloadData()
        totalPrice.text = "0"
    }
    
    func load() {
        ServerUtilities.realm?.invalidate()
        var predicate = NSPredicate(format: "stock > 0 AND active = true")
        if (ApplicationUtilities.CurrentGroup == .PRE_ORDER) {
            predicate = NSPredicate(format: "stock < 1 AND active = true")
        }
        materials = ServerUtilities.getMaterial(predicate: predicate)
        numberOfItems = materials.count
        catalogueView.reloadData()
    }
    
    func load(code: String, type: GroupType) {
        materials = ServerUtilities.getMaterial(group: code, type: type)
        numberOfItems = materials.count
        catalogueView.reloadData()
    }
    
    func setup() {
        searchBars.delegate = self
        let textFieldInsideSearchBar = searchBars.value(forKey: "searchField") as? UITextField
        //textFieldInsideSearchBar?.textColor = UIColor.white
        //textFieldInsideSearchBar?.backgroundColor = UIColor.lightGray
        let leftNavBarButton = UIBarButtonItem(customView: searchBars)
        let attributeDict = [NSForegroundColorAttributeName: UIColor(red: 0.3804, green: 0.4275, blue: 0.8078, alpha: 1.0)]
        textFieldInsideSearchBar!.attributedPlaceholder = NSAttributedString(string: "Search", attributes: attributeDict)
        
        self.navigationItem.leftBarButtonItems?.append(leftNavBarButton)
        
    }
    
    func filter(search: String) {
        filterIndexes.removeAll()
        for i in 0..<materials.count {
            let searchLowercase = search.lowercased()
            let code = materials[i].code.lowercased()
            let desc = materials[i].desc?.lowercased()
            if (code.contains(searchLowercase) || (desc?.contains(searchLowercase))!) {
                filterIndexes.append(i)
            }
        }
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
        cell.delegate = self
        var row = indexPath.row
        if (filterIndexes.count > 0) {
            row = filterIndexes[indexPath.row]
        }
        cell.checked = (trackingFavourites.contains(indexPath.row))
        cell.hideDetails(input: editMode)
        cell.load(material: materials[row], row: (trackingFavourites.contains(row)))
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
        //selectedCell = catalogueView.cellForItem(at: indexPath) as! CatalogueCells
        //performSegue(withIdentifier: "segueMatdetails", sender: nil)
    }
}

extension CatalogueViewController: CatalogueViewControllerDelegate {
    
    func setCollectionViewController(controller: GroupPopOverController, index: Int) {
        if (ApplicationUtilities.CurrentGroup == .FAVOURITE) {
            materials = Array(controller.favourite[index].materials)
            numberOfItems = materials.count
            catalogueView.reloadData()
        } else {
            let code = controller.group[index].code
            switch (ApplicationUtilities.CurrentGroup) {
            case .MAIN_GROUP:
                load(code: code, type: .MAIN_GROUP)
            case .SUB_GROUP:
                load(code: code, type: .SUB_GROUP)
            default:
                load(code: code, type: .NONE)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension CatalogueViewController: CatalogueViewCellDelegate {
    func catalogueCell(_ catalogueCell: CatalogueCells) {
        let index = catalogueView.indexPath(for: catalogueCell)?.row
        //print(index)
        //print(trackingFavourites)
        if (catalogueCell.checked) {
            trackingFavourites.append(index!)
        } else {
            let _index = trackingFavourites.index(of: index!)
            trackingFavourites.remove(at: _index!)
        }
    }
    
    func showAlert(controller: UIAlertController) {
        self.present(controller, animated: true, completion: nil)
    }
    func updatePrice(price: Double) {
        totalPrice.text = "\(price)"
    }
    func performSegueManually(identifier: String) {
        performSegue(withIdentifier: identifier, sender: nil)
    }
    func updateCheckbox(indexCell: CatalogueCells) {
        let indexpath = catalogueView.indexPath(for: indexCell)
        catalogueView.reloadItems(at: [indexpath!])
    }
    
    func resetViewController() {
        resetOrder()
    }
    
    func checkOutOfStock() -> Bool{
        return (ApplicationUtilities.CurrentGroup == .PRE_ORDER)
    }
}

extension CatalogueViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text!
        filter(search: searchText)
        numberOfItems = filterIndexes.count
        catalogueView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterIndexes.removeAll()
        numberOfItems = materials.count
        catalogueView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            filterIndexes.removeAll()
            numberOfItems = materials.count
            catalogueView.reloadData()
        }
    }
}

extension CatalogueViewController: CustomerPopOverDelegate {
    func setCustomer() {
        editMode = false
        addToFavouriteButton.isHidden = !editMode
        if (customerButton.title == "Customer" && ApplicationUtilities.DefaultUser != "") {
            catalogueView.reloadData()
        }
        customerButton.title = ApplicationUtilities.DefaultUser
        if (ApplicationUtilities.DefaultUser == "") {
            customerButton.title = "Customer"
            catalogueView.reloadData()
        }
    }
}

extension CatalogueViewController: FavouritePopOverDelegate {
    func favourite(_ favourite: FavouritePopOverController, didSelectRowAt indexPath: IndexPath) {
        if (editMode) {
            let selectedFavourite = Favourite(value: favourite.favourites[indexPath.row])
            for i in 0..<trackingFavourites.count {
                selectedFavourite.materials.append(materials[trackingFavourites[i]])
            }
            ServerUtilities.saveFavourite(input: selectedFavourite)
            trackingFavourites.removeAll()
            favourite.dismiss(animated: true, completion: nil)
            editMode = !editMode
            addToFavouriteButton.isHidden = !editMode
            catalogueView.reloadData()
        }
    }
}
