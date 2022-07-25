import UIKit
import SDWebImage

protocol FriendRequestViewControllerDelegate {
    func refresh()
}

var friendRequestViewControllerDelegate: FriendRequestViewControllerDelegate?

class FriendRequestViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var sendToMe = [UserProfile]()
    var sentByMe = [UserProfile]()
    
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

        friendRequestViewControllerDelegate = self
        
        setupNavBar()
        fetchRequests()
    }
    
    func setupNavBar() {
        self.navigationItem.title = "Add Requests"
        let rightBarButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

}

// MARK: - UIBUTTON ACTIONS
extension FriendRequestViewController {
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        let items = [Strings.INVITE_FRIEND_TEXT]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    @IBAction func acceptRequset(_ sender: UIButton) {
        let dict = sendToMe[sender.tag]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(1, dict.id)
    }
    
    @IBAction func rejectRequset(_ sender: UIButton) {
        let dict = sendToMe[sender.tag]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(2, dict.id)
    }
    
    @IBAction func cancelRequest(_ sender: UIButton) {
        let dict = sentByMe[sender.tag]
        
        Helper.showLoader(onVC: self)
        self.cancelFriendRequest(dict.id)
    }
}

// MARK: - UITABLEVIEW METHODS
extension FriendRequestViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if sendToMe.count > 0 {
                return sendToMe.count
            }
            else {
                return 1
            }
        }
        else if section == 1 {
            if sentByMe.count > 0 {
                return sentByMe.count
            }
            else {
                return 1
            }
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if sendToMe.count > 0 {
                return setupSendToMe(tableView, indexPath)
            }
            else {
                return setupNoPendingRequests(tableView, indexPath)
            }
        }
        else if indexPath.section == 1 {
            if sentByMe.count > 0 {
                return setupSentByMe(tableView, indexPath)
            }
            else {
                return setupNoPendingRequests(tableView, indexPath)
            }
        }
        else {
            return setupNoPendingRequests(tableView, indexPath)
        }
    }
    
    func setupNoPendingRequests(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.NoPendingRequests, for: indexPath)
        
        return cell
    }
    
    func setupSendToMe(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.FriendRequestCell, for: indexPath) as! FriendRequestCell
        
        let dict = sendToMe[indexPath.row]
        
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
        
        cell.btnAccept.tag = indexPath.row
        cell.btnDecline.tag = indexPath.row
        
        cell.btnAccept.addTarget(self, action: #selector(acceptRequset(_:)), for: .touchUpInside)
        cell.btnDecline.addTarget(self, action: #selector(rejectRequset(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func setupSentByMe(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.CancelFriendRequestCell, for: indexPath) as! CancelFriendRequestCell
        
        let dict = sentByMe[indexPath.row]
        
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

        cell.btnCancel.tag = indexPath.row
        cell.btnCancel.addTarget(self, action: #selector(cancelRequest(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if sendToMe.count > 0 {
                if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                    vc.user = sendToMe[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else if indexPath.section == 1 {
            if sentByMe.count > 0 {
                if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                    vc.user = sentByMe[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Strings.REQUSETS_RECEIVED
        }
        else if section == 1 {
            return Strings.REQUESTS_SENT
        }
        else {
            return Strings.SUGGESTIONS
        }
    }
}

// MARK: - CUSTOM DELEGATE
extension FriendRequestViewController: FriendRequestViewControllerDelegate {
    func refresh() {
        self.sentByMe = []
        self.sendToMe = []
        
        self.fetchRequests()
    }
}

// MARK: - API CALL
extension FriendRequestViewController {
    func fetchRequests() {
        WSManager.wsCallGetFriendRequest { (isSuccess, message, sentByMe, sendToMe) in
            if isSuccess {
                self.sendToMe = sendToMe ?? []
                self.settings?.sendToMe = sendToMe
                
                self.sentByMe = sentByMe ?? []
                self.settings?.sentByMe = sentByMe
                
                self.tableView.reloadData()
            }
            else {
                self.sendToMe = self.settings?.sendToMe ?? []
                self.sentByMe = self.settings?.sentByMe ?? []
                
                self.tableView.reloadData()
            }
        }
    }
    
    func acceptRejectRequset(_ status: Int, _ fromUser: Int) {
        let params: [String: AnyObject] = [WSRequestParams.acceptReject: status as AnyObject,
                                           WSRequestParams.fromUser: fromUser as AnyObject]
        WSManager.wsCallAcceptRejectRequest(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.fetchRequests()
                
                homeViewControllerDelegate?.refreshData()
                userProfileViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
            }
        }
    }
    
    func cancelFriendRequest(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.requestId: id as AnyObject]
        WSManager.wsCallCancelFriendRequest(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.fetchRequests()
                
                homeViewControllerDelegate?.refreshData()
                userProfileViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
}
