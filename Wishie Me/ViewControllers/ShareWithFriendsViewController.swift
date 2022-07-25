import UIKit
import SDWebImage

class ShareWithFriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friends = [UserProfile]()
    var searchFriends = [UserProfile]()
    var videoId: Int?
    var friendId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        fetchFriends()
    }
    
    func setupNavigationBar() {
        let rightBarButton = UIBarButtonItem(title: Strings.SHARE, style: .plain, target: self, action: #selector(shareClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        if friendId != nil {
            Helper.showLoader(onVC: self)
            self.shareVideo(friendId ?? 0)
        }
        else {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.SELECT_FRIEND)
        }
    }
    
    @IBAction func selectionClicked(_ sender: UIButton) {
        let indexPath = IndexPath.init(row: sender.tag, section: 0)
        let dict = friends[indexPath.row]
        dict.isSelected = !dict.isSelected
        
        if dict.isSelected {
            self.friendId = dict.id
        }
        else {
            self.friendId = nil
        }
        
        self.tableView.reloadData()
    }
}

// MARK: - SEARCHBAR DELEGATE
extension ShareWithFriendsViewController: UISearchBarDelegate {    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.friends = self.searchFriends
            self.tableView.reloadData()
        }
        else {
            self.friends = self.searchFriends.filter {
                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }

            self.tableView.reloadData()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension ShareWithFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.LabelMoveCell, for: indexPath) as! LabelMoveCell
        
        let dict = friends[indexPath.row]
        
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                cell.imgProfile.image = Helper.birthdayImage(dict.firstName)
                return
            }
        }

        if let url = URL(string: dict.profileImage) {
            cell.imgProfile.sd_setImage(with: url, completed: block)
        }
        else {
            cell.imgProfile.image = Helper.birthdayImage(dict.firstName)
        }
        
        cell.lblName.text = "\(dict.firstName) \(dict.lastName)"
        
        cell.btnSelection.isSelected = dict.isSelected
        cell.btnSelection.tag = indexPath.row
        cell.btnSelection.addTarget(self, action: #selector(selectionClicked(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - API CALL
extension ShareWithFriendsViewController {
    func fetchFriends() {
        WSManager.wsCallFriends("") { (isSuccess, message, response) in
            self.friends = response ?? []
            self.searchFriends = response ?? []
            
            self.tableView.reloadData()
        }
    }
    
    func shareVideo(_ friendId: Int) {
        let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject,
                                           WSRequestParams.shareWith: friendId as AnyObject]
        WSManager.wsCallShareVideo(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                userProfileViewControllerDelegate?.refreshData()
                cameraViewControllerDelegate?.fromVideoController()
                self.navigationController?.popToRootViewController(animated: true)
                
                DispatchQueue.main.async {
                    cameraViewControllerDelegate?.removeViewFromShare()
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
}
