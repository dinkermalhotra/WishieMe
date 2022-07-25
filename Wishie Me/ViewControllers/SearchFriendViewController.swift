import UIKit
import SDWebImage

class SearchFriendViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoUserFound: UILabel!
    @IBOutlet weak var noInternetView: UIView!
    
    lazy var searchBar = UITextField()
    var users = [UserProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        if !WSManager.isConnectedToInternet() {
            self.tableView.isHidden = true
            self.lblNoUserFound.isHidden = true
            self.noInternetView.isHidden = false
        }
        
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Search Friend"
        
        let frame = self.navigationController?.navigationBar.frame
        searchBar.frame = CGRect.init(x: 0, y: 0, width: frame?.width ?? 0.0, height: 34)
        searchBar.delegate = self
        searchBar.placeholder = "Search wishie"
        searchBar.borderStyle = .none
        searchBar.clearButtonMode = .whileEditing
        searchBar.backgroundColor = WishieMeColors.lightGrayColor
        searchBar.layer.cornerRadius = 17
        searchBar.clipsToBounds = true
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.returnKeyType = .done
        searchBar.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: searchBar.frame.height))
        searchBar.leftViewMode = .always
        searchBar.addTarget(self, action: #selector(searchText(_:)), for: .editingChanged)
        if WSManager.isConnectedToInternet() {
            searchBar.becomeFirstResponder()
        }
        navigationItem.titleView = searchBar
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @IBAction func searchText(_ sender: UITextField) {
        if sender.text?.isEmpty ?? true {
            self.users = []
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        else {
            DispatchQueue.main.async {
                self.searchFriend(sender.text ?? "")
            }
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITEXETFIELD DELEGATE
extension SearchFriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITABLEVIEW METHODS
extension SearchFriendViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.SearchFriendCell, for: indexPath) as! SearchFriendCell
        
        let dict = users[indexPath.row]
        
        cell.lblName.text = "\(dict.firstName) \(dict.lastName)"
        cell.lblUsername.text = "@\(dict.username)"
        
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
        
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = users[indexPath.row]
        if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
            if dict.userBirthday.friend != nil {
                vc.userBirthday = dict.userBirthday
            }
            else {
                vc.user = dict
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - API CALL
extension SearchFriendViewController {
    func searchFriend(_ searchText: String) {
        WSManager.wsCallSearchUser(searchText) { (isSuccess, message, response) in
            if isSuccess {
                if self.searchBar.text?.isEmpty ?? true {
                    self.users = []
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
                else
                {
                    self.users = response ?? []
                    self.lblNoUserFound.isHidden = false
                    self.noInternetView.isHidden = true
                    self.users.count > 0 ? (self.tableView.isHidden = false) : (self.tableView.isHidden = true)
                    self.tableView.reloadData()
                }
            }
            else {
                if message == AlertMessages.NO_INTERNET {
                    self.tableView.isHidden = true
                    self.lblNoUserFound.isHidden = true
                    self.noInternetView.isHidden = false
                }
                else {
                    self.lblNoUserFound.isHidden = false
                    self.noInternetView.isHidden = true
                }
                
                self.users.count > 0 ? (self.tableView.isHidden = false) : (self.tableView.isHidden = true)
                self.tableView.isHidden = true
            }
        }
    }
}
