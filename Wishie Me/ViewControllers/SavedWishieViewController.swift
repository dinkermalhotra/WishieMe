import UIKit
import SDWebImage

class SavedWishieViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var drafts = [Videos]()
    var received = [Videos]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Saved Wishies"
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_MEDIUM_16 ?? UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_MEDIUM_16 ?? UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2, height: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.collectionViewLayout = flowLayout
        
        fetchWishie()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.collectionView.reloadData()
    }
    
}

// MARK: - UICOLLECTIONVIEW METHODS
extension SavedWishieViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return self.received.count
        }
        else {
            return self.drafts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.SavedWishieCell, for: indexPath) as! SavedWishieCell
        
        if segmentControl.selectedSegmentIndex == 0 {
            let dict = received[indexPath.row]
            
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    return
                }
            }

            if let url = URL(string: dict.videoThumbnail) {
                cell.imgPreview.sd_setImage(with: url, completed: block)
            }
        }
        else {
            let dict = drafts[indexPath.row]
            
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    return
                }
            }

            if let url = URL(string: dict.videoThumbnail) {
                cell.imgPreview.sd_setImage(with: url, completed: block)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = segmentControl.selectedSegmentIndex == 0 ? received[indexPath.row] : drafts[indexPath.row]
        
        if let vc = ViewControllerHelper.getViewController(ofType: .VideoShareViewController) as? VideoShareViewController {
            if let url = URL.init(string: dict.video) {
                vc.videoURL = url
                vc.shareVideoUrl = url
            }
            
            vc.thumbnail = dict.videoThumbnail
            vc.isFromSavedWishie = true
            vc.videoId = dict.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - API CALL
extension SavedWishieViewController {
    func fetchWishie() {
        WSManager.wsCallGetSavedWishies { (isSuccess, message, drafts, received) in
            self.drafts = drafts ?? []
            self.received = received ?? []
            
            self.collectionView.reloadData()
        }
    }
}
