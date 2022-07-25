import UIKit
import ContactsUI
import MessageUI
import SDWebImage

protocol FriendProfileViewControllerDelegate {
    func refreshData()
    func updateLabel()
}

var friendProfileViewControllerDelegate: FriendProfileViewControllerDelegate?

class FriendProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgZodiac: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDateOfBirth: UILabel!
    @IBOutlet weak var lblWellWishers: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBio: ExpandableLabel!
    @IBOutlet weak var imgNotes: UIImageView!
    @IBOutlet weak var imgLabel: UIImageView!
    @IBOutlet weak var btnAddFriend: UIButton!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblBlockedUser: UILabel!
    
    var userBirthday: Birthdays?
    var recent: RECENT?
    var user: UserProfile?
    var states = true
    var reminders = [Reminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        friendProfileViewControllerDelegate = self
        setData()
        setupBarButtons()
        
        lblWellWishers.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(wellWishersClicked(_:))))
        imgNotes.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(notesClicked(_:))))
        imgLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(labelClicked(_:))))
        imgProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(profileImageClicked(_:))))
        imgHeader.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(headerImageClicked(_:))))
        
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .vertical
//        flowLayout.itemSize = CGSize(width: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2, height: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2)
//        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
//        self.collectionView.collectionViewLayout = flowLayout
        
        getBirthdayReminders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        self.tableView.addObserver(self, forKeyPath: Strings.CONTENT_SIZE, options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNavBar()
        self.tableView.removeObserver(self, forKeyPath: Strings.CONTENT_SIZE)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Strings.CONTENT_SIZE {
            if let newvalue = change?[.newKey] {
                let newsize  = newvalue as! CGSize
                tableViewHeightConstraint.constant = newsize.height + 88
                viewHeightConstraint.constant = newsize.height + 88
            }
        }
    }
    
    func setupBarButtons() {
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back_background"), style: .plain, target: self, action: #selector(backClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        let menuButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_menu"), style: .plain, target: self, action: #selector(menuClicked(_:)))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func removeNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func createCustomSeperator(_ cell: UITableViewCell) {
        DispatchQueue.main.async {
            let bottomBorder = UIView()
            bottomBorder.frame = CGRect(x: cell.textLabel?.frame.minX ?? 0.0, y: cell.contentView.frame.size.height - 0.5, width: AppConstants.PORTRAIT_SCREEN_WIDTH - (cell.textLabel?.frame.minX ?? 0.0), height: 0.5)
            bottomBorder.backgroundColor = UIColor.groupTableViewBackground
            bottomBorder.tag = 420
            cell.addSubview(bottomBorder)
        }
    }
    
    func removeCustomSeperator(_ cell: UITableViewCell) {
        for subView in cell.subviews {
            if subView.tag == 420 {
                subView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func addFriendClicked(_ sender: UIButton) {
        addFriend()
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuClicked(_ sender: UIBarButtonItem) {
        if user?.isMyFriend ?? false {
            if user?.isBlocked ?? false {
                Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.UNBLOCK, actionOne: unblock, titleTwo: Strings.REPORT, actionTwo: report, styleOneType: .default, styleTwoType: .destructive)
            }
            else {
                Helper.showFourOptionsActionAlert(onVC: self, title: nil, titleOne: Strings.UNFRIEND, actionOne: unfriendClicked, titleTwo: Strings.CHANGE_LABEL, actionTwo: changeLabel, titleThree: Strings.BLOCK, actionThree: block, titleFour: Strings.REPORT, actionFour: report, styleType: .destructive)
            }
        }
        else {
            if user?.isFriendRequestSent ?? false {
                Helper.showThreeWishieOptionActionAlert(onVC: self, title: nil, titleOne: Strings.CANCEL_REQUEST, actionOne: cancelRequest, titleTwo: Strings.BLOCK, actionTwo: block, titleThree: Strings.REPORT, actionThree: report, actionCancel: {
                    
                }, styleType: .destructive)
            }
            else if user?.isFriendRequestReceived ?? false {
                Helper.showFourOptionsActionAlert(onVC: self, title: nil, titleOne: Strings.ACCEPT_REQUEST, actionOne: acceptRequest, titleTwo: Strings.DECLINE_REQUEST, actionTwo: declineRequest, titleThree: Strings.BLOCK, actionThree: block, titleFour: Strings.REPORT, actionFour: report, styleType: .destructive)
            }
            else {
                Helper.showThreeWishieOptionActionAlert(onVC: self, title: nil, titleOne: Strings.ADD_FRIEND, actionOne: addFriend, titleTwo: Strings.BLOCK, actionTwo: block, titleThree: Strings.REPORT, actionThree: report, actionCancel: {
                    
                }, styleType: .destructive)
            }
        }
    }
    
    @IBAction func wellWishersClicked(_ sender: UITapGestureRecognizer) {
        if user?.friendsCount != nil || user?.friendsCount != 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendsViewController) as? FriendsViewController {
                vc.user = user
                vc.userBirthday = userBirthday
                self.navigationController?.pushViewController(vc, animated: true)
            }
//            if let vc = ViewControllerHelper.getViewController(ofType: .FriendsViewController) as? FriendsViewController {
//                if user?.userBirthday.friend != nil {
//                    vc.userBirthday = user?.userBirthday
//                }
//                else {
//                    vc.user = user
//                }
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }
    
    @IBAction func notesClicked(_ sender: UITapGestureRecognizer) {        
        if let vc = ViewControllerHelper.getViewController(ofType: .NotesViewController) as? NotesViewController {
            vc.modalPresentationStyle = .overCurrentContext
            if recent != nil {
                vc.recent = recent
            }
            else {
                vc.userBirthday = userBirthday
            }
            vc.notes = recent != nil ? recent?.note ?? "" : userBirthday?.note ?? ""
            vc.username = recent != nil ? recent?.firstName ?? "" : userBirthday?.firstName ?? ""
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func profileImageClicked(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .FullImageViewController) as? FullImageViewController {
            let navigationController = UINavigationController.init(rootViewController: vc)
            vc.userImage = user?.profileImage ?? ""
            vc.firstName = user?.firstName ?? ""
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func headerImageClicked(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .FullImageViewController) as? FullImageViewController {
            let navigationController = UINavigationController.init(rootViewController: vc)
            vc.userImage = user?.headerImage ?? ""
            vc.firstName = user?.firstName ?? ""
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func labelClicked(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelsViewController) as? LabelsViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func wishieClicked(_ sender: UIButton) {
        let firstName = recent != nil ? recent?.firstName : userBirthday?.firstName
        let text = "\(Strings.HAPPY_BIRTHDAY_WISH) \(firstName ?? "")🥳"
        
        let urlWhats = "whatsapp://send?text=\(text)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                } else {
                    print("Install Whatsapp")
                }
            }
        }
    }
    
    @IBAction func textClicked(_ sender: UIButton) {
        let mobile = recent != nil ? recent?.mobile : userBirthday?.mobile
        let firstName = recent != nil ? recent?.firstName : userBirthday?.firstName
        
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "\(Strings.HAPPY_BIRTHDAY_WISH) \(firstName ?? "")🥳"
            controller.recipients = [mobile ?? ""]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func callClicked(_ sender: UIButton) {
        let mobile = recent != nil ? recent?.mobile : userBirthday?.mobile
        
        if mobile == nil || mobile == "" {
            let contactPicker = CNContactPickerViewController()
            contactPicker.modalPresentationStyle = .overFullScreen
            self.present(contactPicker, animated: true, completion: nil)
        }
        else {
            if let url = URL.init(string: "tel://\(mobile ?? "")") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.MOBLIE_NUMBER_NOT_VALID)
                }
            }
        }
    }
    
    @IBAction func emailClicked(_ sender: UIButton) {
        let email = recent != nil ? recent?.email : userBirthday?.email
        let firstName = recent != nil ? recent?.firstName : userBirthday?.firstName
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email ?? ""])
            mail.setSubject(Strings.HAPPY_BIRTHDAY)
            mail.setMessageBody("\(Strings.HAPPY_BIRTHDAY_WISH) \(firstName ?? "")🥳", isHTML: false)
            self.present(mail, animated: true, completion: nil)
        }
    }
    
    @IBAction func swtComplete(_ sender: UISwitch) {
        if reminders.count > 0 {
            let birthdayId = recent != nil ? recent?.id ?? 0 : userBirthday?.id ?? 0
            updateReminderStatus(birthdayId, NSNumber(value: sender.isOn).intValue)
        }
        else {
            Helper.showSingleActionAlert(onVC: self, title: AlertMessages.CUSTOM_REMINDER, titleOne: Strings.ADD_REMINDER, actionOne: {
                if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
                    vc.birthdayId = self.recent != nil ? self.recent?.id : self.userBirthday?.id
                    vc.labelId = self.recent != nil ? self.recent?.label[0].id ?? 0 : self.userBirthday?.label[0].id ?? 0
                    LocalSettings.isCustomReminder = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }, actionCancel: {
                sender.setOn(false, animated: false)
            })
        }
    }
    
    func addFriend() {
        Helper.showLoader(onVC: self)
        sendFriendRequest()
    }
    
    func cancelRequest() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.CANCEL_REQUEST, message: AlertMessages.CANCEL_REQUEST, btnOkTitle: Strings.YES, btnCancelTitle: Strings.NO, onOk: {
            
            Helper.showLoader(onVC: self)
            self.cancelFriendRequest()
        })
    }
    
    func changeLabel() {        
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelChangeViewController) as? LabelChangeViewController {
            if recent != nil {
                vc.recent = recent
            }
            else {
                vc.userBirthday = userBirthday
            }
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
            
            Helper.showLoader(onVC: self)
            self.blockUser()
        })
    }
    
    func unblock() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.UNBLOCK, message: AlertMessages.UNBLOCK_USER, btnOkTitle: Strings.UNBLOCK, btnCancelTitle: Strings.CANCEL, onOk: {
            
            Helper.showLoader(onVC: self)
            self.unblockUser()
        })
    }
    
    func report() {
        Helper.showFourOptionsActionAlert(onVC: self, title: nil, titleOne: Strings.FAKE_PROFILE, actionOne: fakeProfile, titleTwo: Strings.INAPPROPRIATE_CONTENT, actionTwo: fakeProfile, titleThree: Strings.UNDERAGE_USER, actionThree: fakeProfile, titleFour: Strings.OTHER, actionFour: fakeProfile, styleType: .default)
    }
    
    func fakeProfile() {
        Helper.showLoader(onVC: self)
        
        self.reportUser()
    }
    
    @objc func addReminder(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
            vc.birthdayId = recent != nil ? recent?.id : userBirthday?.id
            vc.labelId = recent != nil ? recent?.label[0].id ?? 0 : userBirthday?.label[0].id ?? 0
            LocalSettings.isCustomReminder = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func wishieClicked() {
        ShareVideo.id = user?.id ?? 0
        ShareVideo.name = user?.firstName ?? ""
        self.tabBarController?.selectedIndex = 2
    }
    
    func unfriendClicked() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.UNFRIEND, message: AlertMessages.UNFRIEND_USER, btnOkTitle: Strings.UNFRIEND, btnCancelTitle: Strings.CANCEL, onOk: {
            
            Helper.showLoader(onVC: self)
            self.unfriendUser()
        })
    }
    
    func acceptRequest() {
        Helper.showLoader(onVC: self)
        
        self.acceptRejectRequset(1, user?.id ?? 0)
    }
    
    func declineRequest() {
        Helper.showLoader(onVC: self)
        
        self.acceptRejectRequset(2, user?.id ?? 0)
    }
    
    func setData() {
        if recent != nil {
            self.user = recent?.friend
            
            if (self.recent?.label.count ?? 0) > 0 {
                let labelColor = UIColor.init(hex: self.recent?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
                self.imgLabel.tintColor = labelColor
            }
        }
        else if userBirthday != nil {
            self.user = userBirthday?.friend
            
            if (self.userBirthday?.label.count ?? 0) > 0 {
                let labelColor = UIColor.init(hex: self.userBirthday?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
                self.imgLabel.tintColor = labelColor
            }
        }
        
        let zodiacDate = Helper.convertedDateForZodiacSign(user?.dob ?? "")
        lblName.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
        lblDateOfBirth.text = "\(Helper.calcAge(user?.dob ?? ""))y • \(user?.dob ?? "") • \(Helper.getZodiacSign(zodiacDate))"
        imgZodiac.image = Helper.getZodiacSignImages(zodiacDate)
        
        //let wellWishers = (user?.friendsCount ?? 0 > 1) ? Strings.WELL_WISHERS.capitalized : Strings.WELL_WISHER.capitalized
        
        if user?.isBlocked ?? true {
            lblWellWishers.text = "0 \(Strings.WELL_WISHERS.capitalized)"
            lblWellWishers.textColor = WishieMeColors.lightGrayColor
            lblWellWishers.isUserInteractionEnabled = false
        }
        else {
            lblWellWishers.text = "\(user?.friendsCount ?? 0) \(Strings.WELL_WISHERS.capitalized)"
            lblWellWishers.textColor = WishieMeColors.greenColor
            lblWellWishers.isUserInteractionEnabled = true
        }
        
        lblUserName.text = "@\(user?.username ?? "")"
        
        let currentSource = self.preparedSources((user?.bio ?? "").condenseWhitespace())
        lblBio.delegate = self
        lblBio.setLessLinkWith(lessLink: "less", attributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: WishieMeColors.darkGrayColor], position: .left)
        lblBio.shouldCollapse = true
        lblBio.textReplacementType = currentSource.textReplacementType
        lblBio.numberOfLines = currentSource.numberOfLines
        lblBio.collapsed = self.states
        lblBio.text = currentSource.text
        
        // profile image
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = Helper.birthdayImage(self.user?.firstName ?? "")
                return
            }
        }
        
        let urlStr = user?.profileImage ?? ""
        let urlString:String = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString as String)
        
        imgProfile.sd_setImage(with: url, completed: block)
        
        // header image
        let headerBlock: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgHeader.image = UIImage(named: "img_user_profile")
                return
            }
        }
        
        let headerUrlStr = user?.headerImage ?? ""
        let headerUrlString:String = headerUrlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headerUrl = URL(string: headerUrlString as String)
        
        imgHeader.sd_setImage(with: headerUrl, completed: headerBlock)
        
        if user?.isBlocked ?? false {
            imgLabel.isHidden = true
            imgNotes.isHidden = true
            tableView.isHidden = true
            contactView.isHidden = true
            btnAddFriend.isHidden = true
            lblBlockedUser.isHidden = false
        }
        else {
            imgLabel.isHidden = false
            imgNotes.isHidden = false
            tableView.isHidden = false
            contactView.isHidden = false
            lblBlockedUser.isHidden = true
        }
        
        if !(user?.isMyFriend ?? false) {
            imgLabel.isHidden = true
            imgNotes.isHidden = true
            tableView.isHidden = true
            contactView.isHidden = true
            lblBlockedUser.isHidden = true
        }
        
        if user?.isFriendRequestSent ?? false || user?.isFriendRequestReceived ?? false {
            btnAddFriend.isHidden = true
            lblBlockedUser.isHidden = true
        }
    }
}

// MARK: - EXPANDEDLABEL DELEGATE
extension FriendProfileViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        states = false
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        states = true
    }
    
    func preparedSources(_ bio: String) -> (text: String, textReplacementType: ExpandableLabel.TextReplacementType, numberOfLines: Int, textAlignment: NSTextAlignment) {
        return (bio, .character, 3, .left)
    }
}

// MARK: - CUSTOM DELEGATE
extension FriendProfileViewController: FriendProfileViewControllerDelegate {
    func refreshData() {
        getBirthdayReminders()
    }
    
    func updateLabel() {
        if recent != nil {            
            if (self.recent?.label.count ?? 0) > 0 {
                let labelColor = UIColor.init(hex: self.recent?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
                self.imgLabel.tintColor = labelColor
            }
        }
        else if userBirthday != nil {
            if (self.userBirthday?.label.count ?? 0) > 0 {
                let labelColor = UIColor.init(hex: self.userBirthday?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
                self.imgLabel.tintColor = labelColor
            }
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension FriendProfileViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension FriendProfileViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW METHODS
extension FriendProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.ReminderCell, for: indexPath)
        
        let dict = reminders[indexPath.row]
        
        if dict.isEnable == 1 {
            cell.textLabel?.isEnabled = true
            cell.detailTextLabel?.isEnabled = true
        }
        else {
            cell.textLabel?.isEnabled = false
            cell.detailTextLabel?.isEnabled = false
        }
        
        cell.textLabel?.text = dict.title
        cell.detailTextLabel?.text = dict.time
        
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
        createCustomSeperator(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            removeCustomSeperator(cell)
        }
        
        let dict = reminders[indexPath.row]
        
        if dict.isEnable == 1 {
            if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
                vc.birthdayId = recent != nil ? recent?.id : userBirthday?.id
                vc.labelId = recent != nil ? recent?.label[0].id ?? 0 : userBirthday?.label[0].id ?? 0
                vc.reminderId = dict.id
                vc.secondaryLabel = [dict.title, dict.time, dict.tone]
                vc.titleStr = Strings.EDIT_REMINDER
                LocalSettings.isCustomReminder = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reminders = self.reminders[indexPath.row]

        let delete = UITableViewRowAction.init(style: .destructive, title: Strings.DELETE) { (action, index) in
            self.deleteReminder(reminders.id)
        }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.CustomRemindersCell) as! CustomRemindersCell
        
        if reminders.count > 0 {
            let dict = reminders[section]
            
            cell.swtComplete.isOn = NSNumber(value: dict.isEnable).boolValue
        }
        else {
            cell.swtComplete.isOn = false
        }
        
        cell.swtComplete.addTarget(self, action: #selector(swtComplete(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.AddReminderCell)
        
        if reminders.count > 0 {
            let dict = reminders[section]
            
            if dict.isEnable == 1 {
                cell?.textLabel?.isEnabled = true
                cell?.imageView?.tintColor = WishieMeColors.greenColor
                
                cell?.contentView.tag = section
                cell?.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addReminder(_:))))
            }
            else {
                cell?.textLabel?.isEnabled = false
                cell?.imageView?.tintColor = .systemGray
            }
        }
        else {
            cell?.textLabel?.isEnabled = false
            cell?.imageView?.tintColor = .systemGray
        }
        
        return cell ?? UITableViewCell()
    }
}

// MARK: - UICOLLECTIONVIEW METHODS
extension FriendProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.wishieReceived?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.SavedWishieCell, for: indexPath) as! SavedWishieCell
        
        let dict = user?.wishieReceived?[indexPath.row]
        
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                return
            }
        }

        if let url = URL(string: dict?.videoThumbnail ?? "") {
            cell.imgPreview.sd_setImage(with: url, completed: block)
        }
        
        return cell
    }
}

// MARK: - API CALL
extension FriendProfileViewController {
    func acceptRejectRequset(_ status: Int, _ fromUser: Int) {
        let params: [String: AnyObject] = [WSRequestParams.acceptReject: status as AnyObject,
                                           WSRequestParams.fromUser: fromUser as AnyObject]
        WSManager.wsCallAcceptRejectRequest(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                friendRequestViewControllerDelegate?.refresh()
                homeViewControllerDelegate?.refreshData()
                userProfileViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                
                if status == 1 {
//                    self.user?.isFriendRequestSent = false
//                    self.user?.isFriendRequestReceived = false
//                    self.user?.isBlocked = false
//                    self.user?.isMyFriend = true
//                    self.user?.friendsCount = self.user?.friendsCount ?? 0 + 1
//
//                    self.setData()
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func sendFriendRequest() {
        let params: [String: AnyObject] = [WSRequestParams.toUser: user?.id as AnyObject]
        WSManager.wsCallSendFriendRequest(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.user?.isFriendRequestSent = true
                self.btnAddFriend.isHidden = true
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
                
                Helper.showOKAlert(onVC: self, title: Alert.SENT, message: message)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func cancelFriendRequest() {
        let params: [String: AnyObject] = [WSRequestParams.requestId: user?.id as AnyObject]
        WSManager.wsCallCancelFriendRequest(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.user?.isFriendRequestSent = false
                self.btnAddFriend.isHidden = false
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                notificationViewControllerDelegate?.refreshData()
                
                Helper.showOKAlert(onVC: self, title: Alert.CANCEL, message: message)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func unfriendUser() {
        let params: [String: AnyObject] = [WSRequestParams.friendId: user?.id as AnyObject]
        WSManager.wsCallUnfriendUser(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                self.user?.isFriendRequestSent = false
                self.user?.isFriendRequestReceived = false
                self.user?.isMyFriend = false
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
                
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
            }
        }
    }
    
    func getBirthdayReminders() {
        let birthdayId = recent != nil ? recent?.id ?? 0 : userBirthday?.id ?? 0
        WSManager.wsCallGetBirthdayReminders(birthdayId) { (isSuccess, message, response)  in
            if isSuccess {
                self.reminders = response ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteReminder(_ id: Int) {
        WSManager.wsCallDeleteBirthdayReminder(id) { (isSuccess, message) in
            if isSuccess {
                self.getBirthdayReminders()
            }
        }
    }
    
    func updateReminderStatus(_ id: Int, _ value: Int) {
        let params: [String: AnyObject] = [WSRequestParams.enableOrDisable: value as AnyObject]
        WSManager.wsCallEnableDisableBirthdayReminder(id, params) { (isSuccess, message) in
            if isSuccess {
                self.getBirthdayReminders()
            }
        }
    }
    
    func blockUser() {
        let params: [String: AnyObject] = [WSRequestParams.friendId: user?.id as AnyObject, WSRequestParams.blockUnblock: 1 as AnyObject]
        WSManager.wsCallBlockUnblockUser(params) { (isSuccess, message) in
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
    
    func reportUser() {
        let params: [String: AnyObject] = [WSRequestParams.userId: user?.id as AnyObject]
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
    
    func unblockUser() {
        let params: [String: AnyObject] = [WSRequestParams.friendId: user?.id as AnyObject, WSRequestParams.blockUnblock: 0 as AnyObject]
        WSManager.wsCallBlockUnblockUser(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            
            if isSuccess {
                if let user = self.user {
                    user.isBlocked = !user.isBlocked
                }
                
                self.setData()
                
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                blockViewControllerDelegate?.refresh()
                userProfileViewControllerDelegate?.refreshData()
                notificationViewControllerDelegate?.refreshData()
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
