//
//  TripMenuTableViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 6/24/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class TripMenuTableViewController: UITableViewController {
    
    weak var delegate: TripMenuDelegate?
    
    enum TripMenuOptions: Int {
        case EditTrip = 0
        case ShareTrip = 1
        case SaveTrip = 2
        case Privacy = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //if this returns a diff number than in the storyboard it will crash
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selection = TripMenuOptions(rawValue: indexPath.row) else {
            return
        }
        
        switch selection {
        case .EditTrip:
            //edit trip
            self.delegate?.didSelectEdit(shouldEdit: true)
            self.dismiss(animated: true, completion: nil)
        case .ShareTrip:
            //share trip
            return
        case .SaveTrip:
            //save trip
            self.delegate?.didSelectSave()
            return
        case .Privacy:
            //public or private toggle
            return
        }
    }
}

protocol TripMenuDelegate: class {
    func didSelectEdit(shouldEdit: Bool)
    func didSelectSave()
}
