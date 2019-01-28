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

//TODO:
//Provide warning if user selects to view a saved trip while there is unsaved data on the page
//create a protocol that can abstract out the mechanism of saving the realm data

class DrawerViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    
    //viewModel items
    var menuItems = ["Save trip", "Clear map", "My trips"]
    var trips: Results<PrimaryLocation>?
    var tableState = DrawerTableState.Menu
    
    //delegate
    weak var menuDelegate: MenuDelegate?
    
    @IBAction func tapMenu(_ sender: Any) {
        self.menuDelegate?.shouldCloseMenu()
        
        self.tableState = .Menu
        self.menuTableView.reloadData()
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
            
            //TODO: encapsulate in change table state method - where we reload the table everytime
            self.tableState = .TripList
            self.menuTableView.reloadData()
        }
        if selection == menuItems[0] {
            self.menuDelegate?.shouldSaveTrip()
            
            tableState = .Menu
            menuTableView.reloadData()
            
            menuDelegate?.shouldCloseMenu()
        }
        if selection == menuItems[1] {
            self.menuDelegate?.shouldClearMap()
            menuDelegate?.shouldCloseMenu()
        }
    }
    
    func handleTripSelection(indexPath: IndexPath) {
        guard let selection = trips?[indexPath.row] else {
            return
        }
        self.menuDelegate?.shouldLoadTrip(trip: selection)
        
        tableState = .Menu
        menuTableView.reloadData()
        
        menuDelegate?.shouldCloseMenu()
    }
}

extension DrawerViewController: HeaderViewDelegate {
    //This may need to become more complicated if we add more navigation possibilities
    func didPressBack() {
        self.tableState = .Menu
        self.menuTableView.reloadData()
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
        switch tableState {
        case .Menu:
            handleMenuSelection(indexPath: indexPath)
        case .TripList:
            handleTripSelection(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.00
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = Bundle.main.loadNibNamed("DrawerHeaderView", owner: self, options: nil)?.first as? DrawerHeaderView else {
            print("Failed to load and cast view")
            return UIView()
        }
        
        header.backgroundColor = UIColor.lightGray
        header.delegate = self
        
        //Hide the back button if the table is in the Menu state
        header.backButton.isHidden = (tableState == .Menu)
        
        switch tableState {
        case .Menu:
            header.headerLabel.text = "Menu"
        case .TripList:
            header.headerLabel.text = "My Trips"
        }
        
        return header
    }
}

extension DrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableState {
        case .Menu:
            return menuItems.count
        case .TripList:
            return trips?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") else {
            return UITableViewCell()
        }
        switch tableState {
        case .Menu:
            cell.textLabel?.text = menuItems[indexPath.row]
            cell.backgroundColor = UIColor.lightGray
            return cell
        case .TripList:
            cell.textLabel?.text = trips?[indexPath.row].locationName
            cell.backgroundColor = UIColor.lightGray
            return cell
        }
    }
}

protocol MenuDelegate: class {
    func shouldCloseMenu()
    func shouldSaveTrip()
    func shouldClearMap()
    func shouldLoadTrip(trip: PrimaryLocation)
}
