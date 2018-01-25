import UIKit

class ViewController: UIViewController {

    //TODO: if we want to have multiple sections expanded at once we could make this a list and check to see what is expanded and what is not
    var expandedSectionHeaders = [Int]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
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
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        header.bubble.layer.cornerRadius = 25.0
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
        cell.bubble.layer.cornerRadius = 16.0
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

