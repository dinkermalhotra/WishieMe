import UIKit
import ContactsUI
import MessageUI
import SDWebImage

protocol UserProfileNotAvailableDelegate {
    func refreshData()
    func updateBirthdayDetails()
}

var userProfileNotAvailableDelegate: UserProfileNotAvailableDelegate?

class UserProfileNotAvailableController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var lblNameShare: UILabel!
    @IBOutlet weak var lblDateOfBirth: UILabel!
    @IBOutlet var lblDateOfBirthShare: UILabel!
    @IBOutlet weak var lblTurning: UILabel!
    @IBOutlet weak var lblTurningShare: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgProfileShare: UIImageView!
    @IBOutlet weak var imgLabel: UIImageView!
    @IBOutlet weak var imgNotes: UIImageView!
    @IBOutlet weak var imgZodiac: UIImageView!
    @IBOutlet weak var imgZodiacShare: UIImageView!
    @IBOutlet weak var btnWishie: UIButton!
    @IBOutlet weak var btnText: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    var userBirthday: Birthdays?
    var recent: RECENT?
    var reminders = [Reminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        userProfileNotAvailableDelegate = self
        imgNotes.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(notesClicked(_:))))
        imgLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(labelClicked(_:))))
        setupNavigationBar()
        
        if recent != nil {
            setRecentData()
        }
        else {
            setBirthdayData()
        }
        
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
                tableViewHeightConstraint.constant = newsize.height
                viewHeightConstraint.constant = newsize.height
            }
        }
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
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let share = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareClicked(_:)))
        share.tintColor = UIColor.white
        
        let more = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_open_menu"), style: .plain, target: self, action: #selector(moreClicked(_:)))
        more.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [more, share]
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
    
    func editBirthday() {
        if let vc = ViewControllerHelper.getViewController(ofType: .CreateBirthdayViewController) as? CreateBirthdayViewController {
            LocalSettings.isEditBirthday = true
            if recent != nil {
                vc.recent = self.recent
            }
            else {
                vc.userBirthday = self.userBirthday
            }
            vc.labelId = recent != nil ? self.recent?.label[0].id ?? 0 : self.userBirthday?.label[0].id ?? 0
            vc.labelName = recent != nil ? self.recent?.label[0].labelName ?? "" : self.userBirthday?.label[0].labelName ?? ""
            vc.labelColor = recent != nil ? self.recent?.label[0].labelColor ?? "" : self.userBirthday?.label[0].labelColor ?? ""
            let navigationController = UINavigationController.init(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func deleteBirthday() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.DELETE, message: AlertMessages.DELETE_BIRTHDAY, btnOkTitle: Strings.YES, btnCancelTitle: Strings.NO, onOk: {
            let birthdayId = self.recent != nil ? self.recent?.id ?? 0 : self.userBirthday?.id ?? 0
            self.deleteBirthday(birthdayId)
        })
    }
    
    func editLabel() {
        
    }
    
    @objc func addReminder(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
            vc.birthdayId = recent != nil ? recent?.id : userBirthday?.id
            vc.labelId = recent != nil ? recent?.label[0].id ?? 0 : userBirthday?.label[0].id ?? 0
            LocalSettings.isCustomReminder = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
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
    
    @IBAction func labelClicked(_ sender: UITapGestureRecognizer) {
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelsViewController) as? LabelsViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreClicked(_ sender: UIBarButtonItem) {
        //Helper.showThreeOptionActionAlert(onVC: self, title: nil, titleOne: Strings.DELETE, actionOne: deleteBirthday, titleTwo: Strings.EDIT, actionTwo: editBirthday, titleThree: Strings.LABEL, actionThree: editLabel)
        Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.DELETE, actionOne: deleteBirthday, titleTwo: Strings.EDIT, actionTwo: editBirthday, styleOneType: .destructive, styleTwoType: .default)
    }
    
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        //let size = CGSize(width: AppConstants.PORTRAIT_SCREEN_WIDTH, height: shareView.frame.origin.y)
        //let items = [self.view.takeScreenshot(size: size)]
        let items = [self.view.image(shareView)]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    @IBAction func wishieClicked(_ sender: UIButton) {
        //self.tabBarController?.selectedIndex = 2
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
    
    @IBAction func inviteClicked(_ sender: UIButton) {
        let items = [Strings.INVITE_FRIEND_TEXT]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
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
}

// MARK: - MFMessageComposeViewControllerDelegate
extension UserProfileNotAvailableController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension UserProfileNotAvailableController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW METHODS
extension UserProfileNotAvailableController: UITableViewDataSource, UITableViewDelegate {
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

// MARK: - CUSTOM DELEGATE
extension UserProfileNotAvailableController: UserProfileNotAvailableDelegate {
    func refreshData() {
        getBirthdayReminders()
    }
    
    func updateBirthdayDetails() {
        if recent != nil {
            setRecentData()
        }
        else {
            setBirthdayData()
        }
    }
}

// MARK: - API CALLS
extension UserProfileNotAvailableController {
    func deleteBirthday(_ id: Int) {
        WSManager.wsCallDeleteBirthday(id) { (isSuccess, message) in
            if isSuccess {
                homeViewControllerDelegate?.refreshData()
                self.dismiss(animated: true, completion: nil)
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
    
    func setBirthdayData() {
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = Helper.birthdayImage(self.userBirthday?.firstName ?? "")
                self.imgProfileShare.image = Helper.birthdayImage(self.userBirthday?.firstName ?? "")
                return
            }
        }

        if let url = URL(string: self.userBirthday?.image ?? "") {
            self.imgProfile.sd_setImage(with: url, completed: block)
            self.imgProfileShare.sd_setImage(with: url, completed: block)
        }

        self.lblName.text = "\(self.userBirthday?.firstName ?? "") \(self.userBirthday?.lastName ?? "")"
        self.lblNameShare.text = "\(self.userBirthday?.firstName ?? "") \(self.userBirthday?.lastName ?? "")"
        
        if (userBirthday?.label.count ?? 0) > 0 {
            let labelColor = UIColor.init(hex: self.userBirthday?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
            self.imgLabel.tintColor = labelColor
        }
        
        var birthDate = self.userBirthday?.birthDate ?? ""
        if birthDate.count > 5 {
            birthDate = String(birthDate.dropFirst(5))
        }
        
        imgZodiac.image = Helper.getZodiacSignImages(birthDate)
        imgZodiacShare.image = Helper.getZodiacSignImages(birthDate)
        if (self.userBirthday?.birthDate.count ?? 0) > 5 {
            self.lblDateOfBirth.text = "\(Helper.convertedDateMonthYear(self.userBirthday?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
            self.lblDateOfBirthShare.text = "\(Helper.convertedDateMonthYear(self.userBirthday?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
        }
        else {
            self.lblDateOfBirth.text = "\(Helper.convertedDateMonth(self.userBirthday?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
            self.lblDateOfBirthShare.text = "\(Helper.convertedDateMonth(self.userBirthday?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
        }
        
        if let turned = self.userBirthday?.turnedAge {
            if birthDate == Helper.todayDate() {
                self.lblTurning.text = "\(Strings.TURNED) \(turned) \(Strings.TODAY.lowercased())"
                self.lblTurningShare.text = "\(Strings.TURNED) \(turned) \(Strings.TODAY.lowercased())"
            }
            else if birthDate == Helper.tomorrowDate() {
                self.lblTurning.text = Strings.BIRTHDAY_TOMORROW
                self.lblTurningShare.text = Strings.BIRTHDAY_TOMORROW
            }
            else {
                self.lblTurning.text = "\(Strings.TURNING) \(turned + 1) in \(self.userBirthday?.daysLeft ?? 0) \(Strings.DAYS)"
                self.lblTurningShare.text = "\(Strings.TURNING) \(turned + 1) in \(self.userBirthday?.daysLeft ?? 0) \(Strings.DAYS)"
            }
        }
        else {
            if birthDate == Helper.todayDate() {
                self.lblTurning.text = Strings.BIRTHDAY_TODAY
                self.lblTurningShare.text = Strings.BIRTHDAY_TODAY
            }
            else if birthDate == Helper.tomorrowDate() {
                self.lblTurning.text = Strings.BIRTHDAY_TOMORROW
                self.lblTurningShare.text = Strings.BIRTHDAY_TOMORROW
            }
            else {
                self.lblTurning.text = "\(Strings.BIRTHDAY) in \(self.userBirthday?.daysLeft ?? 0) \(Strings.DAYS)"
                self.lblTurningShare.text = "\(Strings.BIRTHDAY) in \(self.userBirthday?.daysLeft ?? 0) \(Strings.DAYS)"
            }
        }
    }
    
    func setRecentData() {
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = Helper.birthdayImage(self.recent?.firstName ?? "")
                self.imgProfileShare.image = Helper.birthdayImage(self.recent?.firstName ?? "")
                return
            }
        }

        if let url = URL(string: self.recent?.image ?? "") {
            self.imgProfile.sd_setImage(with: url, completed: block)
            self.imgProfileShare.sd_setImage(with: url, completed: block)
        }

        self.lblName.text = "\(self.recent?.firstName ?? "") \(self.recent?.lastName ?? "")"
        self.lblNameShare.text = "\(self.recent?.firstName ?? "") \(self.recent?.lastName ?? "")"
        
        if (recent?.label.count ?? 0) > 0 {
            let labelColor = UIColor.init(hex: self.recent?.label[0].labelColor.replacingOccurrences(of: "#", with: "") ?? "")
            self.imgLabel.tintColor = labelColor
        }
        
        var birthDate = self.recent?.birthDate ?? ""
        if birthDate.count > 5 {
            birthDate = String(birthDate.dropFirst(5))
        }
        
        imgZodiac.image = Helper.getZodiacSignImages(birthDate)
        imgZodiacShare.image = Helper.getZodiacSignImages(birthDate)
        if (self.recent?.birthDate.count ?? 0) > 5 {
            self.lblDateOfBirth.text = "\(Helper.convertedDateMonthYear(self.recent?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
            self.lblDateOfBirthShare.text = "\(Helper.convertedDateMonthYear(self.recent?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
        }
        else {
            self.lblDateOfBirth.text = "\(Helper.convertedDateMonth(self.recent?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
            self.lblDateOfBirthShare.text = "\(Helper.convertedDateMonth(self.recent?.birthDate ?? "")) • \(Helper.getZodiacSign(birthDate))"
        }
        
        if let turned = self.recent?.turnedAge {
            if birthDate == Helper.todayDate() {
                self.lblTurning.text = "\(Strings.TURNED) \(turned) \(Strings.TODAY.lowercased())"
                self.lblTurningShare.text = "\(Strings.TURNED) \(turned) \(Strings.TODAY.lowercased())"
            }
            else if birthDate == Helper.tomorrowDate() {
                self.lblTurning.text = Strings.BIRTHDAY_TOMORROW
                self.lblTurningShare.text = Strings.BIRTHDAY_TOMORROW
            }
            else {
                self.lblTurning.text = "\(Strings.TURNING) \(turned + 1) in \(self.recent?.daysLeft ?? 0) \(Strings.DAYS)"
                self.lblTurningShare.text = "\(Strings.TURNING) \(turned + 1) in \(self.recent?.daysLeft ?? 0) \(Strings.DAYS)"
            }
        }
        else {
            if birthDate == Helper.tomorrowDate() {
                self.lblTurning.text = Strings.BIRTHDAY_TOMORROW
                self.lblTurningShare.text = Strings.BIRTHDAY_TOMORROW
            }
            else {
                self.lblTurning.text = "\(Strings.BIRTHDAY) in \(self.recent?.daysLeft ?? 0) \(Strings.DAYS)"
                self.lblTurningShare.text = "\(Strings.BIRTHDAY) in \(self.recent?.daysLeft ?? 0) \(Strings.DAYS)"
            }
        }
    }
}
