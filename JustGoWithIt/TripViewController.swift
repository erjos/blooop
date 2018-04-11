import UIKit
import GooglePlaces

class TripViewController: UIViewController {

    var collapsedSectionHeaders = [Int]()
    
    //cant get to this page unless you have a trip
    var trip: Trip!
    
    @IBOutlet weak var tripDate: UILabel!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    //TODO: if the user leaves the main page while still editing, we should turn off edit mode // what would th asd
    @IBAction func rightBarAction(_ sender: Any) {
        if(isEditing){
            setEditing(false, animated: true)
            rightBarItem.title = "•••"
        }else {
            performSegue(withIdentifier: "presentMenu", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
        
        //set name and date labels
        tripName.text = trip?.name!
        tripDate.text = trip?.startDate?.formatDateAsString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as? UINavigationController
        guard let builder = navigation?.viewControllers[0] as? BuilderViewController else {
            let it = "didNotWork"
            print(it) //lol
            return
        }
        
        builder.shouldConfigure = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

class Trip {
    var name: String?
    var startDate: Date?
    var endDate: Date?
    var cities = [City]()
}

class City {
    var googlePlace: GMSPlace
    var locations = [Location]()
    
    init(place: GMSPlace){
        self.googlePlace = place
    }
}

class Location {
    var googlePlace: GMSPlace?
}

extension TripViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Sub location selected by user (contained by main city) - new cities are added via the menu
        let selectedLocation = place
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //Handle error
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension TripViewController: ListHeaderDelegate{
    func shouldExpandOrCollapse(section: Int) {
        let isExpanded = collapsedSectionHeaders.contains(section)
        if(isExpanded){
            //Collapse the cell
            collapsedSectionHeaders = collapsedSectionHeaders.filter({ expanded -> Bool in
                //will remove the expanded section from the list
                return expanded != section
            })
            tableView(self.tableView, numberOfRowsInSection: section)
        } else {
            //expand the section
            collapsedSectionHeaders.append(section)
            tableView(self.tableView, numberOfRowsInSection: section)
        }
        let set = IndexSet.init(integer: section)
        tableView.reloadSections(set, with: UITableViewRowAnimation.automatic)
    }
    
    func didSelectAdd() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension TripViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //TODO: this is the callback after delete is pressed, use this to remove the cells from the table
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeCount = trip.cities[indexPath.section].locations.count
        if(indexPath.row == placeCount){
            performSegue(withIdentifier: "tripToBuilder", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isCollapsed = collapsedSectionHeaders.contains(section)
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        if(!isCollapsed){
            //header.setDropShadow()
        }
        header.arrow.image = isCollapsed ? header.imageRotatedByDegrees(oldImage: header.arrow.image!, deg: -90.0) : header.arrow.image
        header.delegate = self
        header.section = section
        //
        let city = trip.cities[section]
        //set city name on label
        header.mainLabel.text = city.googlePlace.name
//        let sectionCount = trip.cities.count
//        if(section == sectionCount){
//            //configure for last section
//            header.dateLabel.isHidden = true
//            //header.button.isHidden = true
//            header.arrow.image = #imageLiteral(resourceName: "Add")
//            header.arrow.contentMode = .scaleAspectFit
//            header.mainLabel.text = "New Location"
//        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension TripViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let cityCount = trip?.cities.count else{
            return 0
        }
        return cityCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        //TODO: add cell configuration
        
        let placeCount = trip.cities[indexPath.section].locations.count
        
        //row starts at 0; count starts at 1
        if(indexPath.row == placeCount){
            //configure for last cell in list
            cell.cellLabel.text = "+ Add Place"
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shouldCollapse = self.collapsedSectionHeaders.contains(section)
        //TODO: make it easier to retrieve this (push to model)
        let sectionCount = trip.cities.count
        
        //This should only happen if it is the last section in the table (used to add more sections)
        if(section >= sectionCount){
            return 0
        }
        
        let placeCount = trip.cities[section].locations.count
        
        if (shouldCollapse){
            return 0
        } else {
            return placeCount + 1
        }
    }
}

