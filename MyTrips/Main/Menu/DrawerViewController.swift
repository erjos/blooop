//
//  DrawerViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/21/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import UIKit
import RealmSwift
import FirebaseUI

//settings and share button on the trip header - allows you to share and edit permissions (private/public) straight from the trip
//shared trips - shows trips that have been shared w you or trips that you collaborate on with others
//should have a notification badge to indicate when new trips have been shared with you
//Shared with me

//Collab Trips - should this be saved to myTrips or no? Keep separate for now

enum DrawerTableState {
    case Menu
    case MyTrips
    case Notifications
}

protocol MenuDataProtocol {
    mutating func showItem(item: MenuItem)
    mutating func hideItem(item: MenuItem)
    func getVisibleItems()->[MenuItem]
    func getItemFor(indexPath: IndexPath)->MenuItem
}

struct MenuData {
    var itemsList = [(item: MenuItem.NewTrip, isVisible: true), (item: MenuItem.MyTrips, isVisible: true), (item: MenuItem.SignIn, isVisible: true),(item: MenuItem.SignOut, isVisible: false), (item: MenuItem.Notifications, isVisible: true), (item: MenuItem.AboutApp, isVisible: true)]
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
    case SignIn = "Sign in"
    case SignOut = "Sign out"
    case Notifications = "Notifications"
    case AboutApp = "About the app"
}

class DrawerViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var tableHeighConstraint: NSLayoutConstraint!
    
    //stuff
    var menuItems = MenuData()
    var trips: Results<PrimaryLocation>?
    var tableState = DrawerTableState.Menu
    
    //not sure if a lazy variable is the best way to do this
    lazy var firebaseInteractor: FirebaseAuthProtocol = FirebaseInteractor()
    
    var handle: AuthStateDidChangeListenerHandle?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //called when user sign in state changes and called when set to determine how view handles user sign in state
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            //TODO: could also just direct user to signIN when they select shared trips if user is not signed in... might be easier and help with account creation
            guard user != nil else {
                //user is not signed in
                self.menuItems.hideItem(item: .SignOut)
                self.menuItems.showItem(item: .SignIn)
                self.menuTableView.reloadData()
                return
            }
            
            //user is signed in
            self.menuItems.hideItem(item: .SignIn)
            self.menuItems.showItem(item: .SignOut)
            self.menuTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //remove login/user check
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func changeTableState(state: DrawerTableState) {
        self.tableState = state
        self.menuTableView.reloadData()
    }
    
    func presentSignIn() {
        //retrieve authVC from firebase Interactor and present it
        guard let authVC = firebaseInteractor.getAuthViewController(delegate: self) else {
            return
        }
        self.present(authVC, animated: true, completion: nil)
        print("send to sign in")
    }
    
    func handleMenuSelection(indexPath: IndexPath) {
        let selection: MenuItem = menuItems.getItemFor(indexPath: indexPath)
        
        switch selection {
        case .NewTrip:
            menuDelegate?.shouldClearMap(trip: nil)
            menuDelegate?.shouldCloseMenu(menu: self)
        case .MyTrips:
            trips = RealmManager.fetchData()
            changeTableState(state: .MyTrips)
        case .SignIn:
            presentSignIn()
        case .SignOut:
            //sign out
            do {
                try FUIAuth.defaultAuthUI()?.signOut()
            } catch {
                print ("sign out failed")
            }
        case .Notifications:
            //display notifications state
            //check if user is logged in
            guard Auth.auth().currentUser != nil else {
                presentSignIn()
                return
            }
            
            changeTableState(state: .Notifications)
            print("Notifications")
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        //checks to make sure editing is off - keeps edit button working if user swipes to delete
        self.menuTableView.setEditing(false, animated: animated)
        self.menuTableView.setEditing(editing, animated: animated)
    }
}

extension DrawerViewController: HeaderViewDelegate {
    func didPressBack() {
        changeTableState(state: .Menu)
    }
    
    func didPressEdit(shouldEdit: Bool) {
        setEditing(shouldEdit, animated: true)
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
        case .MyTrips:
            handleTripSelection(indexPath: indexPath)
        case .Notifications:
            //show messages...
            print("selected notication")
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
        tableView.setEditing(false, animated: false)
        return header
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            //move this logic to an alert generator...
            let alert = UIAlertController(title: "Are you sure you want to delete this trip?", message: "You will lose all saved data associated with this trip.", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .default) { (action) in
                //get the trip that was selected using the index path
                guard let trip = self.trips?[indexPath.row] else {
                    return
                }
                //delete data from realm
                RealmManager.deletePrimaryLocation(trip: trip)
                //remove from table
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.menuDelegate?.shouldClearMap(trip: trip)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            //throw an alert asking if they're sure they want to delete and will lose all data
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DrawerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableState {
        case .Menu:
            return 1
        case .MyTrips:
            return 1
        case .Notifications:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableState {
        case .Menu:
            let items = menuItems.getVisibleItems()
            self.adjustTableHeight(count: items.count)
            return items.count
        case .MyTrips:
            let count = trips?.count ?? 0
            self.adjustTableHeight(count: count)
            return count
        case .Notifications:
            //once logged in we need to load notifications from the server
            print("load rows for notifications")
            return 3
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
        case .MyTrips:
            cell.textLabel?.text = trips?[indexPath.row].locationName
            return cell
        case .Notifications:
            //load shared trip data onto cell
            cell.textLabel?.text = "Shared Trip1"
            return cell
        }
    }
}

extension DrawerViewController: FUIAuthDelegate {
    //TODO: investigate what needs to be done with refresh token and checking if we are authenticated etc...
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        //recieve sign in callback
        
        //use the user id to associate with other data that we store on the backend
        //ie. trips contain a user id - 
        
    }
}

protocol MenuDelegate: class {
    func shouldCloseMenu(menu: DrawerViewController)
    func shouldClearMap(trip: PrimaryLocation?)
    func shouldLoadTrip(trip: PrimaryLocation)
    
    //might be able to pull this function
    func shouldShowAboutApp()
}
