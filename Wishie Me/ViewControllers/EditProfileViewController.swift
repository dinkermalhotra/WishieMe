import UIKit
import SDWebImage

class EditProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userProfile: Profile?
    var userDetails = [String]()
    var isHeaderImage = false
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(updateData(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PROFILE), object: nil)
        
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.tintColor = WishieMeColors.greenColor
        
        if let userProfile = self.userProfile {
            setData(userProfile)
        }
    }
    
    func setData(_ profile: Profile) {
        let phoneNumber = profile.phone == "" ? "" : parseNumber("+\(profile.phone)")
        userDetails = ["\(profile.firstName) \(profile.lastName)", profile.bio, profile.dob, profile.email, phoneNumber, "@\(profile.username)", "********"]
        self.tableView.reloadData()
    }
    
    func parseNumber(_ number: String) -> String {
        let countryCode = PhoneNumberRecognition.parseNumber(number)
        if countryCode.count <= 6 {
            let newNumber = number.replacingOccurrences(of: countryCode, with: "\(countryCode) ")
            return newNumber
        }
        else {
            return "+\(number)"
        }
    }
    
    func performLogout() {
        UserData.clear()
        
        settings?.accessToken = ""
        settings?.email = ""
        settings?.firstName = ""
        settings?.lastName = ""
        settings?.phone = ""
        settings?.profileImage = ""
        settings?.userId = 0
        settings?.username = ""
        
        // local storage
        settings?.birthdays = nil
        settings?.blockedUser = nil
        settings?.friends = nil
        settings?.labels = nil
        settings?.notifications = nil
        settings?.profile = nil
        settings?.recents = nil
        settings?.reminders = nil
        settings?.sendToMe = nil
        settings?.sentByMe = nil
        
        dismiss(animated: true, completion: nil)
    }
    
    func createCustomSeperator(_ cell: UITableViewCell) {
        DispatchQueue.main.async {
            let bottomBorder = UIView()
            bottomBorder.frame = CGRect(x: cell.textLabel?.frame.minX ?? 0.0, y: cell.contentView.frame.size.height - 0.5, width: AppConstants.PORTRAIT_SCREEN_WIDTH - (cell.textLabel?.frame.minX ?? 0.0), height: 0.5)
            bottomBorder.backgroundColor = WishieMeColors.lightGrayColor
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
    
    @objc func updateData(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let userProfile = notificationUserInfo[UPDATE_PROFILE] as? Profile {
                self.userProfile = userProfile
                self.setData(userProfile)
            }
        }
    }
    
    @IBAction func profileImageClicked(_ sender: UIButton) {
        isHeaderImage = false
        
        if userProfile?.profileImage == nil || userProfile?.profileImage.isEmpty ?? true {
            Helper.showActionAlert(onVC: self, title: Alert.PROFILE_IMAGE, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
        }
        else {
            Helper.showThreeOptionActionAlert(onVC: self, title: Alert.PROFILE_IMAGE, titleOne: Strings.REMOVE_PHOTO, actionOne: removePhoto, titleTwo: Strings.TAKE_PHOTO, actionTwo: takeNewPhotoFromCamera, titleThree: Strings.CHOOSE_PHOTO, actionThree: choosePhotoFromExistingImages)
        }        
    }
    
    @IBAction func headerImageClicked(_ sender: UIButton) {
        isHeaderImage = true
        
        if userProfile?.headerImage == nil || userProfile?.headerImage.isEmpty ?? true {
            Helper.showActionAlert(onVC: self, title: Alert.COVER_IMAGE, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
        }
        else {
            Helper.showThreeOptionActionAlert(onVC: self, title: Alert.COVER_IMAGE, titleOne: Strings.REMOVE_PHOTO, actionOne: removePhoto, titleTwo: Strings.TAKE_PHOTO, actionTwo: takeNewPhotoFromCamera, titleThree: Strings.CHOOSE_PHOTO, actionThree: choosePhotoFromExistingImages)
        }
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.LOGOUT, message: AlertMessages.LOGOUT, btnOkTitle: Strings.LOGOUT, btnCancelTitle: Strings.CANCEL, onOk: {
            
            self.performLogout()
        })
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(indexPath.row)", for: indexPath)
        
        cell.detailTextLabel?.text = userDetails[indexPath.row].condenseWhitespace()
        
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
        createCustomSeperator(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            removeCustomSeperator(cell)
//        }
        
        if indexPath.row == 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditNameViewController) as? EditNameViewController {
                vc.firstName = userProfile?.firstName ?? ""
                vc.lastName = userProfile?.lastName ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 1 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditBioViewController) as? EditBioViewController {
                vc.bio = userProfile?.bio ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 2 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditBirthdayViewController) as? EditBirthdayViewController {
                vc.birthday = Helper.userBirthdate(userProfile?.dob ?? "")
                vc.day = Helper.userBirthday(userProfile?.dob ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 3 || indexPath.row == 4 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditContactDetailsViewController) as? EditContactDetailsViewController {
                vc.email = userProfile?.email ?? Strings.ADD
                vc.mobile = userProfile?.phone ?? Strings.ADD
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 5 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditUsernameViewController) as? EditUsernameViewController {
                vc.username = userProfile?.username ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 6 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditPasswordViewController) as? EditPasswordViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AppConstants.PORTRAIT_SCREEN_HEIGHT / 3.2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditProfileCell) as! EditProfileCell
        
        // profile image
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                cell.imgProfile.image = Helper.birthdayImage(self.userProfile?.firstName ?? "")
                return
            }
        }
        
        let urlStr = userProfile?.profileImage ?? ""
        let urlString:String = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString as String)
        
        cell.imgProfile.sd_setImage(with: url, completed: block)
        cell.imgProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(profileImageClicked(_:))))
        
        // haeader image
        let headerBlock: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                cell.imgHeader.image = nil
                return
            }
        }
        
        let headerUrlStr = userProfile?.headerImage ?? ""
        let headerUrlString:String = headerUrlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headerUrl = URL(string: headerUrlString as String)
        
        cell.imgHeader.sd_setImage(with: headerUrl, completed: headerBlock)
        cell.imgHeader.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(headerImageClicked(_:))))
        
        return cell.contentView
    }
}

// MARK: - UIIMAGEPICKERCONTROLLER DELEGAT
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takeNewPhotoFromCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.camera
        self.present(picker, animated: true, completion: nil)
    }
    
    func choosePhotoFromExistingImages() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func removePhoto() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.REMOVE_PHOTO, message: AlertMessages.REMOVE_PHOTO, btnOkTitle: Strings.REMOVE, btnCancelTitle: Strings.CANCEL, onOk: {
            if self.isHeaderImage {
                self.editHeaderImage(nil)
            }
            else {
                self.editImage(nil)
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        DispatchQueue.main.async {
            let imageData = editedImage.jpegData(compressionQuality: 0.5)
            
            if self.isHeaderImage {
                self.editHeaderImage(imageData)
            }
            else {
                self.editImage(imageData)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - API CALL
extension EditProfileViewController {
    func editImage(_ imageData: Data?) {
        let params: [String: AnyObject] = [WSRequestParams.profileImage: Helper.convertBase64ImageRemove(imageData) as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
        }
    }
    
    func editHeaderImage(_ imageData: Data?) {
        let params: [String: AnyObject] = [WSRequestParams.headerImage: Helper.convertBase64ImageRemove(imageData) as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
        }
    }
}
