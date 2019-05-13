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

protocol MenuDataProtocol {
    mutating func showItem(item: MenuItem)
    mutating func hideItem(item: MenuItem)
    func getVisibleItems()->[MenuItem]
    func getItemFor(indexPath: IndexPath)->MenuItem
}

struct MenuData {
    var itemsList = [(item: MenuItem.NewTrip, isVisible: true), (item: MenuItem.MyTrips, isVisible: true), (item: MenuItem.AboutApp, isVisible: true)]
}

extension MenuData : MenuDataProtocol {
    func getItemFor(indexPath: IndexPath)->MenuItem{
        let items = getVisibleItems()
        return items[indexPath.row]
    }
    
    mutating func showItem(item: MenuItem) {
        toggleItemVisibility(item: item, isVisble: true)
    }
    
    mutating func hideItem(item: MenuItem) {
        toggleItemVisibility(item: item, isVisble: false)
    }
    
    func getVisibleItems() -> [MenuItem] {
        return itemsList.filter{$0.isVisible}
            .map{$0.item}
    }
    
    private mutating func toggleItemVisibility(item: MenuItem, isVisble: Bool){
        itemsList = itemsList.map{
            if($0.item == item){
                return (item, isVisble)
            }
            return $0
        }
    }
}

enum MenuItem: String {
    case NewTrip = "New trip"
    case MyTrips = "My trips"
    case AboutApp = "About the app"
}

class DrawerViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var tableHeighConstraint: NSLayoutConstraint!
    
    //stuff
    var menuItems = MenuData()
    var trips: Results<PrimaryLocation>?
    var tableState = DrawerTableState.Menu
    
    let HEADER_HEIGHT = 75
    let CELL_HEIGHT = 44
    let HEADER_VIEW = "DrawerHeaderView"
    let CELL_REUSE_ID = "menuCell"
    
    //delegate
    weak var menuDelegate: MenuDelegate?
    
    @IBAction func tapMenu(_ sender: Any) {
        self.menuDelegate?.shouldCloseMenu(menu: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_REUSE_ID)
        menuTableView.separatorColor = UIColor.black
    }
    
    func changeTableState(state: DrawerTableState){
        self.tableState = state
        self.menuTableView.reloadData()
    }
    
    func handleMenuSelection(indexPath: IndexPath) {
        let selection: MenuItem = menuItems.getItemFor(indexPath: indexPath)
        
        switch selection {
        case .NewTrip:
            menuDelegate?.shouldClearMap()
            menuDelegate?.shouldCloseMenu(menu: self)
        case .MyTrips:
            trips = RealmManager.fetchData()
            changeTableState(state: .TripList)
        case .AboutApp:
            self.performSegue(withIdentifier: "showAboutApp", sender: self)
        }
    }
    
    func handleTripSelection(indexPath: IndexPath) {
        guard let selection = trips?[indexPath.row] else {
            return
        }
        self.menuDelegate?.shouldLoadTrip(trip: selection)
        changeTableState(state: .Menu)
        menuDelegate?.shouldCloseMenu(menu: self)
    }
    
    func adjustTableHeight(count:Int){
        //TODO: have to change this if we modify design of the table (ie. header and footer)
        self.tableHeighConstraint.constant = CGFloat((CELL_HEIGHT * count) + HEADER_HEIGHT + HEADER_HEIGHT)
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
        return CGFloat(HEADER_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(HEADER_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: HEADER_HEIGHT)
        let footer = UIView(frame: rect)
        
        footer.backgroundColor = UIColor.init(red: 45, green: 45, blue: 45)
        return footer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = Bundle.main.loadNibNamed(HEADER_VIEW, owner: self, options: nil)?.first as? DrawerHeaderView else {
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
            let items = menuItems.getVisibleItems()
            self.adjustTableHeight(count: items.count)
            return items.count
        case .TripList:
            let count = trips?.count ?? 0
            self.adjustTableHeight(count: count)
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_ID) else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor.init(red: 55, green: 55, blue: 55)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.lineBreakMode = .byClipping
        cell.selectionStyle = .none
        
        switch tableState {
        case .Menu:
            cell.textLabel?.text = menuItems.getItemFor(indexPath: indexPath).rawValue
            return cell
        case .TripList:
            cell.textLabel?.text = trips?[indexPath.row].locationName
            return cell
        }
    }
}

protocol MenuDelegate: class {
    func shouldCloseMenu(menu: DrawerViewController)
    func shouldClearMap()
    func shouldLoadTrip(trip: PrimaryLocation)
    
    //might be able to pull this function
    func shouldShowAboutApp()
}
