import UIKit
import SDWebImage

class FriendsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noInternetView: UIView!
    
    var user: UserProfile?
    var userBirthday: Birthdays?
    var userProfile: Profile? // from own profile
    var friends = [UserProfile]()
    var searchFriends = [UserProfile]()
    var selectedIndex = 0
    
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
        
        setupNavigationBar()
        fetchFriends()
    }
    
    func setupNavigationBar() {
        let username = userProfile != nil ? userProfile?.username : user?.username
        self.navigationItem.title = username
        
        let searchBarButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchClicked(_:)))
        searchBarButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = searchBarButton
    }
    
    func showFilter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.searchBarTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func hideFilter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.searchBarTopConstraint.constant = -60
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.view.endEditing(true)
            self.searchBar.text = ""
            self.friends = self.searchFriends
            self.tableView.reloadData()
        }
    }
    
    func changeLabel() {
        let dict = self.friends[self.selectedIndex]
        
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelChangeViewController) as? LabelChangeViewController {
            vc.userBirthday = dict.userBirthday
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func share() {
        let items = [Strings.INVITE_FRIEND_TEXT]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    func block() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.BLOCK, message: AlertMessages.BLOCK_USER, btnOkTitle: Strings.BLOCK, btnCancelTitle: Strings.CANCEL, onOk: {
            
            let dict = self.friends[self.selectedIndex]
            
            Helper.showLoader(onVC: self)
            self.blockUser(dict.id)
        })
    }
    
    func addFriend() {
        let dict = friends[self.selectedIndex]
        
        Helper.showLoader(onVC: self)
        sendFriendRequest(dict.id)
    }
    
    func cancelRequest() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.CANCEL_REQUEST, message: AlertMessages.CANCEL_REQUEST, btnOkTitle: Strings.YES, btnCancelTitle: Strings.NO, onOk: {
            
            let dict = self.friends[self.selectedIndex]
            
            Helper.showLoader(onVC: self)
            self.cancelFriendRequest(dict.id)
        })
    }
    
    func unblock() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.UNBLOCK, message: AlertMessages.UNBLOCK_USER, btnOkTitle: Strings.UNBLOCK, btnCancelTitle: Strings.CANCEL, onOk: {
            
            let dict = self.friends[self.selectedIndex]
            
            Helper.showLoader(onVC: self)
            self.unblockUser(dict.id)
        })
    }
    
    func report() {
        Helper.showFourOptionsActionAlert(onVC: self, title: nil, titleOne: Strings.FAKE_PROFILE, actionOne: fakeProfile, titleTwo: Strings.INAPPROPRIATE_CONTENT, actionTwo: fakeProfile, titleThree: Strings.UNDERAGE_USER, actionThree: fakeProfile, titleFour: Strings.OTHER, actionFour: fakeProfile, styleType: .default)
    }
    
    func fakeProfile() {
        let dict = friends[self.selectedIndex]
        
        Helper.showLoader(onVC: self)
        self.reportUser(dict.id)
    }
    
    func unfriendClicked() {
        let dict = friends[self.selectedIndex]
        
        Helper.showLoader(onVC: self)
        self.unfriendUser(dict.id)
    }
    
    func acceptRequest() {
        let dict = friends[self.selectedIndex]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(1, dict.id)
    }
    
    func declineRequest() {
        let dict = friends[self.selectedIndex]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(2, dict.id)
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func acceptRequestClicked(_ sender: UIButton) {
        let dict = friends[sender.tag]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(1, dict.id)
    }
    
    @IBAction func declineRequestClicked(_ sender: UIButton) {
        let dict = friends[sender.tag]
        
        Helper.showLoader(onVC: self)
        self.acceptRejectRequset(2, dict.id)
    }
    
    @IBAction func addClicked(_ sender: UIButton) {
        let dict = friends[sender.tag]
        
        Helper.showLoader(onVC: self)
        sendFriendRequest(dict.id)
    }
    
    @IBAction func cancelRequestClicked(_ sender: UIButton) {
        let dict = friends[sender.tag]
        
        Helper.showLoader(onVC: self)
        cancelFriendRequest(dict.id)
    }
    
    @IBAction func moreClicked(_ sender: UIButton) {
        self.selectedIndex = sender.tag
        let dict = self.friends[sender.tag]
        
        if dict.isMyFriend {
            if dict.isBlocked {
                Helper.showActionAlert(onVC: self, isViewRequired: true, imageString: dict.profileImage, name: "\(dict.firstName) \(dict.lastName)", title: "\n\n\n\n", titleOne: Strings.UNBLOCK, actionOne: unblock, titleTwo: Strings.REPORT, actionTwo: report, styleOneType: .default, styleTwoType: .destructive)
            }
            else {
                Helper.showFourOptionsActionAlert(onVC: self, isViewRequired: true, imageString: dict.profileImage, name: "\(dict.firstName) \(dict.lastName)", title: "\n\n\n\n", titleOne: Strings.UNFRIEND, actionOne: unfriendClicked, titleTwo: Strings.CHANGE_LABEL, actionTwo: changeLabel, titleThree: Strings.BLOCK, actionThree: block, titleFour: Strings.REPORT, actionFour: report, styleType: .destructive)
            }
        }
        else {
            if dict.isFriendRequestSent {
                Helper.showThreeWishieOptionActionAlert(onVC: self, isViewRequired: true, imageString: dict.profileImage, name: "\(dict.firstName) \(dict.lastName)", title: "\n\n\n\n", titleOne: Strings.CANCEL_REQUEST, actionOne: cancelRequest, titleTwo: Strings.BLOCK, actionTwo: block, titleThree: Strings.REPORT, actionThree: report, actionCancel: {
                    
                }, styleType: .destructive)
            }
            else if dict.isFriendRequestReceived {
                Helper.showFourOptionsActionAlert(onVC: self, isViewRequired: true, imageString: dict.profileImage, name: "\(dict.firstName) \(dict.lastName)", title: "\n\n\n\n", titleOne: Strings.ACCEPT_REQUEST, actionOne: acceptRequest, titleTwo: Strings.DECLINE_REQUEST, actionTwo: declineRequest, titleThree: Strings.BLOCK, actionThree: block, titleFour: Strings.REPORT, actionFour: report, styleType: .destructive)
            }
            else {
                Helper.showThreeWishieOptionActionAlert(onVC: self, isViewRequired: true, imageString: dict.profileImage, name: "\(dict.firstName) \(dict.lastName)", title: "\n\n\n\n", titleOne: Strings.ADD_FRIEND, actionOne: addFriend, titleTwo: Strings.BLOCK, actionTwo: block, titleThree: Strings.REPORT, actionThree: report, actionCancel: {
                    
                }, styleType: .destructive)
            }
        }
    }
    
    @IBAction func retryClicked(_ sender: UIButton) {
        fetchFriends()
    }
    
    @IBAction func searchClicked(_ sender: UIBarButtonItem) {
        if self.searchBarTopConstraint.constant == 0 {
            hideFilter()
        }
        else {
            if userProfile != nil {
                searchBar.placeholder = ""
            }
            else {
                searchBar.placeholder = Strings.SEARCH_WELL_WISHERS
            }
            
            showFilter()
        }
    }
}

// MARK: - SEARCHBAR DELEGATE
extension FriendsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideFilter()
    }
    
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
extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.FriendsCell, for: indexPath) as! FriendsCell
       
        let dict = friends[indexPath.row]
        
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
        
        if dict.id == settings?.userId {
            cell.btnAdd.isHidden = true
            cell.btnCancel.isHidden = true
            cell.btnMore.isHidden = true
            cell.btnDecline.isHidden = true
            cell.btnAccept.isHidden = true
        }
        else {
            if dict.isMyFriend {
                cell.btnAdd.isHidden = true
                cell.btnCancel.isHidden = true
                cell.btnMore.isHidden = false
                cell.btnDecline.isHidden = true
                cell.btnAccept.isHidden = true
            }
            else if dict.isFriendRequestSent {
                cell.btnAdd.isHidden = true
                cell.btnCancel.isHidden = false
                cell.btnMore.isHidden = true
                cell.btnDecline.isHidden = true
                cell.btnAccept.isHidden = true
            }
            else if dict.isFriendRequestReceived {
                cell.btnAdd.isHidden = true
                cell.btnCancel.isHidden = true
                cell.btnMore.isHidden = true
                cell.btnDecline.isHidden = false
                cell.btnAccept.isHidden = false
            }
            else {
                cell.btnAdd.isHidden = false
                cell.btnCancel.isHidden = true
                cell.btnMore.isHidden = true
                cell.btnDecline.isHidden = true
                cell.btnAccept.isHidden = true
            }
        }
        
        cell.btnAdd.tag = indexPath.row
        cell.btnCancel.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        cell.btnDecline.tag = indexPath.row
        cell.btnAccept.tag = indexPath.row
        
        cell.btnAdd.addTarget(self, action: #selector(addClicked(_:)), for: .touchUpInside)
        cell.btnCancel.addTarget(self, action: #selector(cancelRequestClicked(_:)), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(moreClicked(_:)), for: .touchUpInside)
        cell.btnAccept.addTarget(self, action: #selector(acceptRequestClicked(_:)), for: .touchUpInside)
        cell.btnDecline.addTarget(self, action: #selector(declineRequestClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = friends[indexPath.row]
        
        if dict.id == settings?.userId {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileViewController) as? UserProfileViewController {
                vc.ifNotFromTab = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
//            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
//                vc.user = dict
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let firstName = userProfile != nil ? userProfile?.firstName : user?.firstName
        let friendsCount = userProfile != nil ? userProfile?.friendsCount : user?.friendsCount
        
        //let wellWishers = (friendsCount ?? 0 > 1) ? Strings.WELL_WISHERS : Strings.WELL_WISHER
        
        if userProfile != nil {
            return "\(Strings.WELL_WISHERS) (\(friendsCount ?? 0))"
        }
        else {
            return "\(firstName?.uppercased() ?? "")'s \(Strings.WELL_WISHERS) (\(friendsCount ?? 0))"
        }
    }
}

// MARK: - API CALL
extension FriendsViewController {
    func fetchFriends() {
        let id = userProfile != nil ? userProfile?.id : user?.id
        WSManager.wsCallFriends("\(id ?? 0)") { (isSuccess, message, response) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.friends = response ?? []
                self.searchFriends = response ?? []
                
                if self.userProfile != nil {
                    self.settings?.friends = response
                }
                
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            else {
                if self.userProfile != nil {
                    self.friends = self.settings?.friends ?? []
                    self.searchFriends = self.settings?.friends ?? []
                    self.tableView.reloadData()
                }
                else {
                    if message == AlertMessages.NO_INTERNET {
                        self.tableView.isHidden = true
                    }
                }
            }
        }
    }
    
    func acceptRejectRequset(_ status: Int, _ fromUser: Int) {
        let params: [String: AnyObject] = [WSRequestParams.acceptReject: status as AnyObject,
                                           WSRequestParams.fromUser: fromUser as AnyObject]
        WSManager.wsCallAcceptRejectRequest(params) { (isSuccess, message) in
            
            if isSuccess {
                self.fetchFriends()
                
                homeViewControllerDelegate?.refreshData()
                userProfileViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
            }
            else {
                Helper.hideLoader(onVC: self)
                
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func sendFriendRequest(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.toUser: id as AnyObject]
        WSManager.wsCallSendFriendRequest(params) { (isSuccess, message) in
            
            if isSuccess {
                self.fetchFriends()
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
                
                Helper.showOKAlert(onVC: self, title: Alert.SENT, message: message)
            }
            else {
                Helper.hideLoader(onVC: self)
                
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func blockUser(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.friendId: id as AnyObject, WSRequestParams.blockUnblock: 1 as AnyObject]
        WSManager.wsCallBlockUnblockUser(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                blockViewControllerDelegate?.refresh()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
                
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func reportUser(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.userId: id as AnyObject]
        WSManager.wsCallReportUser(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
                
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func unfriendUser(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.friendId: id as AnyObject]
        WSManager.wsCallUnfriendUser(params) { (isSuccess, message) in
            if isSuccess {
                self.fetchFriends()
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
            }
            else {
                Helper.hideLoader(onVC: self)
                
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func unblockUser(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.friendId: id as AnyObject, WSRequestParams.blockUnblock: 0 as AnyObject]
        WSManager.wsCallBlockUnblockUser(params) { (isSuccess, message) in
            
            if isSuccess {
                self.fetchFriends()
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                blockViewControllerDelegate?.refresh()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
            }
            else {
                Helper.hideLoader(onVC: self)
                
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func cancelFriendRequest(_ id: Int) {
        let params: [String: AnyObject] = [WSRequestParams.requestId: id as AnyObject]
        WSManager.wsCallCancelFriendRequest(params) { (isSuccess, message) in
            
            if isSuccess {
                self.fetchFriends()
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
                
                Helper.showOKAlert(onVC: self, title: Alert.CANCEL, message: message)
            }
            else {
                Helper.hideLoader(onVC: self)
                
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
}
