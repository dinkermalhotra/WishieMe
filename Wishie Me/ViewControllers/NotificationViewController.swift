import UIKit
import SDWebImage

struct NotificationObject {
    var sectionName: String?
    var sectionObjects: [Notifications]?
}

protocol NotificationViewControllerDelegate {
    func refreshData()
}

var notificationViewControllerDelegate: NotificationViewControllerDelegate?

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationObject]()
    var refreshControl = UIRefreshControl()
    
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
        
        notificationViewControllerDelegate = self
        
        setupNotificationManager()
        setupNavigationBar()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settings?.lastTabIndex = 3
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Notifications"
        
        let searchBarButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchClicked(_:)))
        searchBarButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = searchBarButton
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_friend_request"), style: .plain, target: self, action: #selector(friendClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(sendToDraft(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SEND_TO_DRAFT), object: nil)
    }
    
    @objc func sendToDraft(_ notification: Notification) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SavedWishieViewController) as? SavedWishieViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        self.fetchNotifications()
    }
    
    @IBAction func searchClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SearchFriendViewController) as? SearchFriendViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func friendClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .FriendRequestViewController) as? FriendRequestViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications[section].sectionObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.NotificationBirthdayCell, for: indexPath) as! NotificationBirthdayCell
        
        let dict = notifications[indexPath.section]
        let notificationObject = dict.sectionObjects?[indexPath.row]
        
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                cell.imgProfile.image = Helper.birthdayImage(notificationObject?.user?.firstName ?? "")
                return
            }
        }

        if notificationObject?.user != nil {
            if let url = URL(string: notificationObject?.user?.image ?? "") {
                cell.imgProfile.sd_setImage(with: url, completed: block)
            }
            else {
                cell.imgProfile.image = Helper.birthdayImage(notificationObject?.user?.firstName ?? "")
            }
        }
        else {
            if let url = URL(string: notificationObject?.fromUser?.userBirthday.image ?? "") {
                cell.imgProfile.sd_setImage(with: url, completed: block)
            }
            else {
                cell.imgProfile.image = Helper.birthdayImage(notificationObject?.user?.firstName ?? "")
            }
        }
        
        if notificationObject?.user?.firstName != nil {
            let attributedString = NSMutableAttributedString.init(string: notificationObject?.notification ?? "")
            attributedString.addAttribute(.font, value: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_14 ?? UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 5, length: (notificationObject?.user?.firstName.count ?? 0) + 2))
            cell.lblTitle.attributedText = attributedString
        }
        else {
            let name = "\(notificationObject?.fromUser?.firstName ?? "") \(notificationObject?.fromUser?.lastName ?? "")"
            let attributedString = NSMutableAttributedString.init(string: notificationObject?.notification ?? "")
            attributedString.addAttribute(.font, value: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_14 ?? UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 0, length: name.count))
            cell.lblTitle.attributedText = attributedString
        }
        
        cell.lblTime.text = Helper.notificationTime((notificationObject?.notifyDate ?? "") ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = notifications[indexPath.section]
        let notificationObject = dict.sectionObjects?[indexPath.row]
        
        if notificationObject?.user != nil {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                vc.userBirthday = notificationObject?.user ?? Birthdays()
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        else {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                if notificationObject?.fromUser?.userBirthday.friend != nil {
                    vc.userBirthday = notificationObject?.fromUser?.userBirthday
                }
                else {
                    vc.user = notificationObject?.fromUser
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.notifications[section].sectionName
    }
}

// MARK: - CUSTOM DELEGATE
extension NotificationViewController: NotificationViewControllerDelegate {
    func refreshData() {
        fetchNotifications()
    }
}

// MARK: - API CALL
extension NotificationViewController {
    func fetchNotifications() {
        WSManager.wsCallGetNotifications { (isSuccess, message, response, jsonData) in
            self.notifications = []
            
            if isSuccess {
                self.settings?.notifications = jsonData
                self.setData(response ?? [:])
            }
            else {
                if message == AlertMessages.NO_INTERNET {
                    Helper.showToast(onVC: self)
                }
                
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: self.settings?.notifications ?? Data(), options: []) as? [String: Any] {
                        if let notifications = NotificationResponse.init(JSON: dictionary), let result = notifications.results {
                            self.setData(result)
                        }
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setData(_ response: [String: [Notifications]]) {
        let myArrayOfTuples = response.sorted {
            guard let d1 = $0.key.shortDate, let d2 = $1.key.shortDate else { return false }
            return d1 > d2
        }
        
        for (key, value) in myArrayOfTuples {
            var days: String?
            
            if key == Helper.getTodayDate() {
                days = Strings.TODAY
            }
            else if key == Helper.getYesterdayDate() {
                days = Strings.YESTERDAY
            }
            else {
                days = Helper.notificationHeaderDate(key)
            }
            
            let newValue = value.sorted { (notification1, notification2) -> Bool in
                return (notification1.notifyDate ?? "") ?? "" > (notification2.notifyDate ?? "") ?? ""
            }
            
            self.notifications.append(NotificationObject(sectionName: days, sectionObjects: newValue))
        }
        
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
}
