import UIKit

class ListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var collectionView: TableCollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //Sets the data source and delegate for the collection view
    func setupCollectionView
        <dataSourceDelegate: UICollectionViewDelegate & UICollectionViewDataSource>
        (viewController: dataSourceDelegate, forIndexPath indexPath: IndexPath){
        collectionView.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        collectionView.dataSource = viewController
        collectionView.delegate = viewController
        collectionView.rowLocation = indexPath
        collectionView.reloadData()
    }
    
    func loadCollectionPhotos(){
        
    }
    
    func configureLastCell(){
        //TODO: create set cell methods to show and hide the correct things so that dequeued cells dont break
        collectionView.isHidden = true
        activityLabel.isHidden = true
        dateLabel.isHidden = true
        locationLabel.text = "+ Add Place"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class TableCollectionView: UICollectionView {
    //allows us to quickly set/store and lookup the location of a collection view inside the table view
    var rowLocation: IndexPath?
}
