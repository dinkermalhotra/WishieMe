import UIKit
import SDWebImage

protocol BlockViewControllerDelegate {
    func refresh()
}

var blockViewControllerDelegate: BlockViewControllerDelegate?

class BlockViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [UserProfile]()
    
    var _settings: SettingsManager?
    
    var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Blocked"
        blockViewControllerDelegate = self
        
        Helper.showLoader(onVC: self)
        self.fetchBlockedUser()
    }
    
    @IBAction func unblockClicked(_ sender: UIButton) {
        let dict = users[sender.tag]
        
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.UNBLOCK, message: AlertMessages.UNBLOCK_USER, btnOkTitle: Strings.UNBLOCK, btnCancelTitle: Strings.CANCEL, onOk: {
            Helper.showLoader(onVC: self)
            self.unblockUser(dict.id)
        })
    }
}

// MARK: - UITABLEVIEW METHODS
extension BlockViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.CancelFriendRequestCell, for: indexPath) as! CancelFriendRequestCell
        
        let dict = users[indexPath.row]
        
        cell.lblName.text = "\(dict.firstName) \(dict.lastName)"

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

        cell.btnCancel.tag = indexPath.row
        cell.btnCancel.addTarget(self, action: #selector(unblockClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
            vc.user = users[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CUSTOM DELEGATE
extension BlockViewController: BlockViewControllerDelegate {
    func refresh() {
        self.users = []
        
        fetchBlockedUser()
    }
}

// MARK: - API CALL
extension BlockViewController {
    func fetchBlockedUser() {
        WSManager.wsCallBlockList { (isSuccess, message, response) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.users = response ?? []
                self.settings?.blockedUser = response
                self.users.count > 0 ? (self.tableView.isHidden = false) : (self.tableView.isHidden = true)
                self.tableView.reloadData()
            }
            else {
                self.users = self.settings?.blockedUser ?? []
                self.users.count > 0 ? (self.tableView.isHidden = false) : (self.tableView.isHidden = true)
                self.tableView.reloadData()
            }
        }
    }
    
    func unblockUser(_ friendId: Int) {
        let params: [String: AnyObject] = [WSRequestParams.friendId: friendId as AnyObject, WSRequestParams.blockUnblock: 0 as AnyObject]
        WSManager.wsCallBlockUnblockUser(params) { (isSuccess, message) in
            if isSuccess {
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
                
                self.fetchBlockedUser()
            }
            else {
                Helper.hideLoader(onVC: self)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
