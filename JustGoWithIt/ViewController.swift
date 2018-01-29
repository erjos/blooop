import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    //TODO: if we want to have multiple sections expanded at once we could make this a list and check to see what is expanded and what is not
    var expandedSectionHeaders = [Int]()
    @IBOutlet weak var tableView: UITableView!
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
        
        //TODO:Move this into an edit button on the menu page
        //setEditing(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: ListHeaderDelegate{
    func shouldExpandOrCollapse(section: Int) {
        let isExpanded = expandedSectionHeaders.contains(section)
        if(isExpanded){
            //Collapse the cell
            expandedSectionHeaders = expandedSectionHeaders.filter({ expanded -> Bool in
                //will remove the expanded section from the list
                return expanded != section
            })
            tableView(self.tableView, numberOfRowsInSection: section)
        } else {
            //expand the section
            expandedSectionHeaders.append(section)
            tableView(self.tableView, numberOfRowsInSection: section)
        }
        let set = IndexSet.init(integer: section)
        tableView.reloadSections(set, with: UITableViewRowAnimation.automatic)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //TODO: this is the callback after delete is pressed, use this to remove the cells from the table
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isExpanded = expandedSectionHeaders.contains(section)
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        if(isExpanded){
            header.setDropShadow()
        }
        header.arrow.image = isExpanded ? header.arrow.image : header.imageRotatedByDegrees(oldImage: header.arrow.image!, deg: -90.0)
        header.delegate = self
        header.section = section
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension ViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shouldExpand = self.expandedSectionHeaders.contains(section)
        if (shouldExpand){
            return 3
        } else {
            return 0
        }
    }
}

