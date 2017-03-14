//
//  FavouritePopOverController.swift
//  OPTO e-Catalogue
//
//  Created by Nhat Tran on 2/1/17.
//  Copyright © 2017 TedBinary. All rights reserved.
//

import UIKit

protocol FavouritePopOverDelegate {
    func favourite(_ favourite: FavouritePopOverController, didSelectRowAt indexPath: IndexPath)
}

class FavouritePopOverController: UIViewController {
    
    @IBOutlet weak var favouriteView: UITableView!
    var favourites = [Favourite]()
    var numberOfItems = 0
    var delegate: FavouritePopOverDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favouriteView.delegate = self
        favouriteView.dataSource = self
        load()
    }
    
    @IBAction func newFavourite(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Favourite", message: "Enter your favourite name.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            let name = alert.textFields?[0].text
            let favourite = Favourite()
            favourite.name = name!
            favourite.employee = ApplicationUtilities.loginUser
            ServerUtilities.saveFavourite(input: favourite)
            self.load()
            self.favouriteView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!)
    {
        
    }
    
    func load() {
        favourites.removeAll()
        let predicate = NSPredicate(format: "employee = %@", ApplicationUtilities.loginUser)
        favourites = ServerUtilities.getFavourite(predicate: predicate)
        numberOfItems = favourites.count
        favouriteView.reloadData()
    }
    
}

extension FavouritePopOverController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (delegate != nil) {
            delegate?.favourite(self, didSelectRowAt: indexPath)
        }
    }
}

extension FavouritePopOverController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favouriteView.dequeueReusableCell(withIdentifier: "favouriteCells", for: indexPath) as! FavouriteCell
        cell.name.text = favourites[indexPath.row].name
        return cell
    }
}


