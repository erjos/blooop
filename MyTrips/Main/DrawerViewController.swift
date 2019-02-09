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
    @IBOutlet weak var tableHeighConstraint: NSLayoutConstraint!
    
    //viewModel stuff
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
    
    func changeTableState(state: DrawerTableState){
        self.tableState = state
        self.menuTableView.reloadData()
    }
    
    func handleMenuSelection(indexPath: IndexPath) {
        let selection = menuItems[indexPath.row]
        
        switch selection {
        case menuItems[0]:
            self.menuDelegate?.shouldSaveTrip()
            changeTableState(state: .Menu)
            menuDelegate?.shouldCloseMenu()
        case menuItems[1]:
            self.menuDelegate?.shouldClearMap()
            menuDelegate?.shouldCloseMenu()
        case menuItems[2]:
            self.trips = RealmManager.fetchData()
            changeTableState(state: .TripList)
        default:
            return
        }
    }
    
    func handleTripSelection(indexPath: IndexPath) {
        guard let selection = trips?[indexPath.row] else {
            return
        }
        self.menuDelegate?.shouldLoadTrip(trip: selection)
        changeTableState(state: .Menu)
        menuDelegate?.shouldCloseMenu()
    }
}

extension DrawerViewController: HeaderViewDelegate {
    func didPressBack() {
        changeTableState(state: .Menu)
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
        header.delegate = self
        
        header.setupHeaderView(tableState: tableState)
        
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
