//
//  DrawerViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/21/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import UIKit
import RealmSwift

enum DrawerTableState {
    case Menu
    case TripList
}

class DrawerViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    
    var menuItems = ["Save trip", "Clear map", "My trips"]
    var trips: Results<PrimaryLocation>?
    var tableState = DrawerTableState.Menu
    
    weak var menuDelegate: MenuDelegate?
    
    @IBAction func tapMenu(_ sender: Any) {
        self.menuDelegate?.shouldCloseMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        menuTableView.separatorColor = UIColor.darkGray
    }
    
    func handleMenuSelection(indexPath: IndexPath) {
        let selection = menuItems[indexPath.row]
        //Move this to a switch statement
        if selection == menuItems[2] {
            self.trips = RealmManager.fetchData()
            //TODO: create method to handle UI switch to display these trips?
            //table refresh - just encapsulate it
        }
        if selection == menuItems[0] {
            self.menuDelegate?.shouldSaveTrip()
        }
        if selection == menuItems[1] {
            self.menuDelegate?.shouldClearMap()
        }
    }
}

extension DrawerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard let touchView = touch.view else {
            return true
        }
        
        if touchView.isDescendant(of: self.menuTableView) {
            return false
        }
        
        return true
    }
}

extension DrawerViewController: UITableViewDelegate {
    //handle tapping of specific items in the menu - for some we want to close the drawer for others we want to keep it open and change the state of the page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableState == .Menu{
            handleMenuSelection(indexPath: indexPath)
        }else {
            
        }
    }
}

extension DrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableState == .Menu {
            return menuItems.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableState == .Menu {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
            cell?.textLabel?.text = menuItems[indexPath.row]
            cell?.backgroundColor = UIColor.lightGray
            return cell!
        } else {
            return UITableViewCell()
        }
    }
}

protocol MenuDelegate: class {
    func shouldCloseMenu()
    func shouldSaveTrip()
    func shouldClearMap()
}
