import UIKit
import CoreData
import MapKit
import CoreLocation


class ShopsViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var shopsCollectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    
    weak var delegate: MainViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
        
        //Location & Center
        let madridLocation = CLLocation(latitude: 40.416775, longitude: -3.703790)
        self.map.setCenter(madridLocation.coordinate, animated: true)
        
        //Zoom
        let region = MKCoordinateRegion(center: madridLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let reg = self.map.regionThatFits(region)
        self.map.setRegion(reg, animated: true)
       
       // Download all shops once
        ExecuteOnceInteractorImp().execute(id: "Shops") {
               inicialize()
        }
        
        self.shopsCollectionView.dataSource = self
        self.shopsCollectionView.delegate = self
        
        }
    
    //MARK: Inline func
    func  inicialize(){
        
        let downloadShopsInteractor: DownloadAllShopsInteractor = DownloadAllShopsInteractorNSURLSessionImpl()
        
        downloadShopsInteractor.execute(onSuccess: { (shops: Shops) in
            //Network connection ok
            SetExecuteOneInteractorImp().execute(id:"Shops")
            let cacheInteractor = SaveAllShopsInteractorImpl()
            cacheInteractor.execute(shops: shops, context: self.context, onSuccess: { (shops: Shops) in
                self._fetchedResultsController = nil
                self.shopsCollectionView.dataSource = self
                self.shopsCollectionView.delegate = self
                self.shopsCollectionView.reloadData()
                
            })
        }) { (error) in
            //Network connection ko
            print("💩 Error \(error.localizedDescription)")
            
            //pop
            self.navigationController?.popViewController(animated: true)
            
            //Error Message
            let alert = UIAlertController(title: "Network Error", message: "Network error", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true){}
            

            //There are Data
            self.shopsCollectionView.dataSource = self
            self.shopsCollectionView.delegate = self
            
        }
        
        
    }
        
        
      
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let shopCD = self.fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "ShowShopDetailSegue", sender: shopCD)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowShopDetailSegue" {
            let vc = segue.destination as! ShopViewDetailController
            
            let shopCD: ShopCD = sender as! ShopCD
            vc.shop = mapShopCDIntoShop(shopCD: shopCD)
        }
    }
    
    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<ShopCD>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<ShopCD> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<ShopCD> = ShopCD.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: "ShopsCacheFile")
        
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }


}


