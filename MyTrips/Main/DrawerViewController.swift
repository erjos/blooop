//
//  DrawerViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/21/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    
    var menuItems = ["Save trip", "Clear map", "My trips"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        menuTableView.separatorColor = UIColor.darkGray
    }
    
}

extension DrawerViewController: UITableViewDelegate {
    
}

extension DrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
        cell?.textLabel?.text = menuItems[indexPath.row]
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
}
