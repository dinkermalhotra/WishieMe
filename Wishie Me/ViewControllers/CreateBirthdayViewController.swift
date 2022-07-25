import UIKit
import CountryPickerView
import SDWebImage

protocol CreateBirthdayViewControllerDelegate {
    func updatedNote(_ note: String)
    func addFromPhoneBook(_ firstName: String, _ lastName: String, _ mobile: String, _ profileImage: Data)
}

var createBirthdayViewControllerDelegate: CreateBirthdayViewControllerDelegate?

class CreateBirthdayViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtLabel: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtNote: UITextField!
    @IBOutlet weak var picker: PickerView!
    @IBOutlet weak var swtYear: UISwitch!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var btnAddLabel: UIButton!
    @IBOutlet weak var btnAddBirthday: UIButton!
    @IBOutlet weak var btnAddNote: UIButton!
    @IBOutlet weak var txtEmailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBirthday: UIView!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var btnContactPicker: UIButton!
    
    var labels = [Labels]()
    var userBirthday: Birthdays?
    var recent: RECENT?
    var birthday = ""
    var imageData: Data?
    var isPickerHidden = false
    var isUserProfile = false
    var labelId: Int = 3
    var labelColor = ""
    var labelName = Strings.FRIENDS
    var notes = ""
    var firstName = ""
    var lastName = ""
    var mobileNumber = ""
    var rightBarButton = UIBarButtonItem()
    var savedBirthYear = ""
    var isUserUpdatedImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        countryPicker.dataSource = self
        countryPicker.delegate = self
        countryPicker.showCountryCodeInView = false
        countryPicker.countryDetailsLabel.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        
        createBirthdayViewControllerDelegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        imgProfile.layer.cornerRadius = 50
        imgProfile.clipsToBounds = true
        
        imgProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(profileImageClicked(_:))))
        contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(endEditing)))
        
        showHidePickerView()
        fetchLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalSettings.isEditBirthday ?? false {
            let name = recent != nil ? "\(recent?.firstName ?? "") \(recent?.lastName ?? "")" : "\(userBirthday?.firstName ?? "") \(userBirthday?.lastName ?? "")"
            self.navigationItem.title = name
            recent != nil ? setRecentData() : setBirthdayData()
            checkBarButtonStatus()
            setupNavBar()
            
            if isUserProfile {
                imgProfile.isUserInteractionEnabled = false
                txtFirstName.isUserInteractionEnabled = false
                txtLastName.isUserInteractionEnabled = false
                txtEmail.isUserInteractionEnabled = false
                txtMobile.isUserInteractionEnabled = false
                btnAddNote.isUserInteractionEnabled = false
                btnAddBirthday.isUserInteractionEnabled = false
                btnPhoto.isUserInteractionEnabled = false
            }
        }
        else {
            self.navigationItem.title = "New birthday"
            btnAddLabel.setTitle(labelName, for: UIControl.State())
            checkBarButtonStatus()
            setupNavBar()
            
            if firstName.isEmpty {
                btnContactPicker.isHidden = false
            }
            
            txtFirstName.text = firstName
            txtLastName.text = lastName
            
            if let data = self.imageData {
                let image = UIImage.init(data: data)
                imgProfile.image = image
            }
            
            if !mobileNumber.isEmpty {
                if mobileNumber.starts(with: "0") {
                    mobileStartsWithZero(mobileNumber)
                }
                else {
                    var mobile = mobileNumber
                    mobile = mobile.replacingOccurrences(of: "-", with: "")
                    mobile = mobile.replacingOccurrences(of: " ", with: "")
                    parseNumber(mobile)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNavBar()
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
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func endEditing() {
        self.contentView.endEditing(true)
    }
    
    func checkBarButtonStatus() {
        if (txtFirstName.text?.isEmpty ?? true) || btnAddBirthday.titleLabel?.text == Strings.ADD {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
        else {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
    }
    
    func setCurrentDate() {
        if btnAddBirthday.titleLabel?.text == Strings.ADD {
            if swtYear.isOn {
                self.birthday = Helper.birthdayCurrentDate()
                self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
            }
            else {
                self.birthday = Helper.birthdayCurrentDateWithoutYear()
                self.btnAddBirthday.setTitle(Helper.dateMonth(self.birthday), for: UIControl.State())
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.checkBarButtonStatus()
            })
        }
        else {
            if swtYear.isOn {
                if self.savedBirthYear.isEmpty {
                    if LocalSettings.isEditBirthday ?? false {
                        if self.birthday.count > 5 {
                            self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
                        }
                        else {
                            self.birthday = "\(self.birthday)-\(Helper.getCurrentYear())"
                            self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
                        }
                    }
                    else {
                        self.birthday = "\(self.birthday)-\(Helper.getCurrentYear())"
                        self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
                    }
                }
                else {
                    if self.birthday.count < 5 {
                        self.birthday = "\(self.birthday)-\(String(self.savedBirthYear.suffix(4)))"
                        self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
                    }
                }
            }
            else {
                if self.birthday.count > 6 {
                    self.birthday = String(self.birthday.dropLast(5))
                    self.btnAddBirthday.setTitle(Helper.dateMonth(self.birthday), for: UIControl.State())
                }
            }
        }
    }
    
    func showPicker() {
        if picker.isYearHidden ?? false {
            picker.onDateSelect = {(date: Int, month: Int) in
                self.birthday = "\(date)-\(month)"
                self.btnAddBirthday.setTitle(Helper.dateMonth(self.birthday), for: UIControl.State())
                self.checkBarButtonStatus()
            }
        }
        else {
            picker.onDateSelected = {(date: Int, month: Int, year: Int) in
                self.savedBirthYear = "\(date)-\(month)-\(year)"
                self.birthday = "\(date)-\(month)-\(year)"
                self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
                self.checkBarButtonStatus()
            }
        }
    }
    
    func showHidePickerView() {
        if pickerView.isHidden {
            txtEmailTopConstraint.constant = 16
            txtEmailTopConstraint.priority = .required
            viewHeightConstraint.constant = 207
            viewBirthday.isHidden = false
        }
        else {            
            txtEmailTopConstraint.constant = 306
            txtEmailTopConstraint.priority = .defaultLow
            viewHeightConstraint.constant = 411
            viewBirthday.isHidden = true
        }
    }
    
    func parseNumber(_ number: String) {
        if !number.isEmpty && number.count > 5 {
            let countryCode = PhoneNumberRecognition.parseNumber(number)
            if countryCode.count <= 6 {
                self.countryPicker.countryDetailsLabel.text = countryCode
                let newNumber = number.replacingOccurrences(of: countryCode, with: "")
                self.txtMobile.text = newNumber.replacingOccurrences(of: " ", with: "")
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: countryCode)
            }
        }
    }
    
    func mobileStartsWithZero(_ mobileNumber: String) {
        let mobile = mobileNumber.dropFirst()
        self.txtMobile.text = String(mobile)
    }
    
    func removePhoto() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.REMOVE_PHOTO, message: AlertMessages.REMOVE_PHOTO, btnOkTitle: Strings.REMOVE, btnCancelTitle: Strings.CANCEL, onOk: {
            let defaultImage = Helper.birthdayImage(self.txtFirstName.text ?? "")
            self.imgProfile.image = defaultImage
            self.isUserUpdatedImage = false
            self.checkBarButtonStatus()
            
            self.imageData = defaultImage.jpegData(compressionQuality: 1.0)
            self.btnPhoto.setTitle(Strings.UPLOAD_PHOTO, for: UIControl.State())
        })
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            if #available(iOS 11.0, *) {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - bottomLayoutGuide.length, right: 0)
            }
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        LocalSettings.clearIsEditBirthday()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if !(txtFirstName.text?.isEmpty ?? true) && btnAddBirthday.titleLabel?.text != Strings.ADD {
            self.contentView.endEditing(true)
            pickerView.isHidden = true
            showHidePickerView()
            
            Helper.showLoader(onVC: self)
            if LocalSettings.isEditBirthday ?? false {
                editBirthday()
            }
            else {
                createBirthday()
            }
        }
    }
    
    @IBAction func phonebookClicked(_ sender: UIButton) {
        if let vc = ViewControllerHelper.getViewController(ofType: .InviteFriendsViewController) as? InviteFriendsViewController {
            vc.isFromCreateNewBirthday = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func profileImageClicked(_ gesture: UITapGestureRecognizer) {
        pickerView.isHidden = true
        showHidePickerView()
        
        if !isUserUpdatedImage {
            Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
        }
        else {
            Helper.showThreeOptionActionAlert(onVC: self, title: nil, titleOne: Strings.REMOVE_PHOTO, actionOne: removePhoto, titleTwo: Strings.TAKE_PHOTO, actionTwo: takeNewPhotoFromCamera, titleThree: Strings.CHOOSE_PHOTO, actionThree: choosePhotoFromExistingImages)
        }
    }
    
    @IBAction func showHideYear(_ sender: UISwitch) {
        if sender.isOn {
            picker.isYearHidden = false
            picker.commonSetup()
            showPicker()
        }
        else {
            picker.isYearHidden = true
            picker.commonSetup()
            showPicker()
        }
        
        setCurrentDate()
    }
    
    @IBAction func uploadPicture(_ sender: UIButton) {
        pickerView.isHidden = true
        showHidePickerView()
        
        if !isUserUpdatedImage {
            Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
        }
        else {
            Helper.showThreeOptionActionAlert(onVC: self, title: nil, titleOne: Strings.REMOVE_PHOTO, actionOne: removePhoto, titleTwo: Strings.TAKE_PHOTO, actionTwo: takeNewPhotoFromCamera, titleThree: Strings.CHOOSE_PHOTO, actionThree: choosePhotoFromExistingImages)
        }
    }
    
    @IBAction func addLabelClicked(_ sender: UIButton) {
        pickerView.isHidden = true
        showHidePickerView()
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        for label in self.labels {
            let action: UIAlertAction = UIAlertAction(title: label.labelName, style: .default) { action -> Void in
                self.labelName = label.labelName
                self.labelId = label.id
                self.labelColor = label.labelColor
                sender.setTitle(label.labelName, for: UIControl.State())
            }
            
            actionSheetController.addAction(action)
        }
        
        let oneActionButton: UIAlertAction = UIAlertAction(title: "New label", style: .default) { action -> Void in
            if let vc = ViewControllerHelper.getViewController(ofType: .LabelsViewController) as? LabelsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        actionSheetController.addAction(oneActionButton)
        
        if let popoverPresentationController = actionSheetController.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            var rect = self.view.frame;
            
            rect.origin.x = self.view.frame.size.width / 20;
            rect.origin.y = self.view.frame.size.height / 20;
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = rect
        }
        
        actionSheetController.view.tintColor = WishieMeColors.greenColor
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func addBirthdayClicked(_ sender: UIButton) {
        self.contentView.endEditing(true)
        if pickerView.isHidden {
            pickerView.isHidden = false
            showHidePickerView()
            
            if swtYear.isOn {
                picker.isYearHidden = false
                picker.commonSetup()
                showPicker()
            }
            else {
                picker.isYearHidden = true
                picker.commonSetup()
                showPicker()
            }
        }
        else {
            pickerView.isHidden = true
            showHidePickerView()
            checkBarButtonStatus()
        }
        
        setCurrentDate()
    }
    
    @IBAction func addNoteClicked(_ sender: UIButton) {
        self.contentView.endEditing(true)
        pickerView.isHidden = true
        showHidePickerView()
        
        if let vc = ViewControllerHelper.getViewController(ofType: .NotesViewController) as? NotesViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.notes = notes
            vc.username = txtFirstName.text ?? "Note"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        checkBarButtonStatus()
    }
}

// MARK: - COUNTRYPICKER DATASOURCE
extension CreateBirthdayViewController: CountryPickerViewDataSource, CountryPickerViewDelegate {
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return countryPickerView.tag == countryPicker.tag && true
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        print(country.phoneCode)
        self.parseNumber("\(country.phoneCode)\(txtMobile.text ?? "")")
    }
}

// MARK: - CreateBirthdayViewControllerDelegate
extension CreateBirthdayViewController: CreateBirthdayViewControllerDelegate {
    func updatedNote(_ note: String) {
        self.notes = note
        if note != "" {
            self.btnAddNote.setTitle(Strings.EDIT, for: UIControl.State())
        }
        else {
            self.btnAddNote.setTitle(Strings.ADD, for: UIControl.State())
        }
    }
    
    func addFromPhoneBook(_ firstName: String, _ lastName: String, _ mobile: String, _ profileImage: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.btnContactPicker.isHidden = true
            
            self.firstName = firstName
            self.lastName = lastName
            self.imageData = profileImage
            self.mobileNumber = mobile
            
            self.txtFirstName.text = firstName
            self.txtLastName.text = lastName
            
            let image = UIImage.init(data: profileImage)
            self.imgProfile.image = image
            
            if image?.size == CGSize(width: 128, height: 128) || image?.size == CGSize(width: 512, height: 512) {
                self.isUserUpdatedImage = false
            }
            else {
                self.isUserUpdatedImage = true
            }
            
            if mobile.starts(with: "0") {
                self.mobileStartsWithZero(mobile)
            }
            else {
                self.parseNumber(mobile)
            }
        })
    }
}

// MARK: - UIIMAGEPICKERCONTROLLER DELEGAT
extension CreateBirthdayViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        DispatchQueue.main.async {
            self.imgProfile.image = editedImage
            self.isUserUpdatedImage = true
            self.checkBarButtonStatus()
            
            self.imageData = editedImage.jpegData(compressionQuality: 0.5)
            self.btnPhoto.setTitle(Strings.CHANGE_PHOTO, for: UIControl.State())
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension CreateBirthdayViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName {
            txtLastName.becomeFirstResponder()
        }
        else if textField == txtLastName {
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            txtMobile.becomeFirstResponder()
        }
        else {
            txtMobile.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerView.isHidden = true
        showHidePickerView()
        
        if textField == txtLabel || textField == txtBirthday || textField == txtNote {
            return false
        }
        else {
            return true
        }
    }
}

// MARK: - API CALL
extension CreateBirthdayViewController {
    func fetchLabels() {
        WSManager.wsCallGetLabels { (isSuccess, message, response) in
            if isSuccess {
                self.labels = response ?? []
            }
        }
    }
    
    func createBirthday() {
        var mobile = ""
        if !(txtMobile.text?.isEmpty ?? false) {
            mobile = "\(countryPicker.countryDetailsLabel.text ?? "")\(txtMobile.text ?? "")"
        }
        
        let params: [String: AnyObject] = [WSRequestParams.image: Helper.convertBase64Image(imageData) as AnyObject,
                                           WSRequestParams.firstName: txtFirstName.text as AnyObject,
                                           WSRequestParams.lastName: txtLastName.text as AnyObject,
                                           WSRequestParams.label: [labelId] as AnyObject,
                                           WSRequestParams.birthday: self.birthday as AnyObject,
                                           WSRequestParams.email: txtEmail.text as AnyObject,
                                           WSRequestParams.mobile: mobile as AnyObject,
                                           WSRequestParams.note: notes as AnyObject]
        WSManager.wsCallCreateBirthday(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                LocalSettings.clearIsEditBirthday()
                labelsViewControllerDelegate?.refreshLabels()
                homeViewControllerDelegate?.refreshData()
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func editBirthday() {
        var mobile = ""
        if !(txtMobile.text?.isEmpty ?? false) {
            mobile = "\(countryPicker.countryDetailsLabel.text ?? "")\(txtMobile.text ?? "")"
        }
        
        let birthdayId = recent != nil ? recent?.id ?? 0 : userBirthday?.id ?? 0
        let params: [String: AnyObject] = [WSRequestParams.image: Helper.convertBase64Image(imageData) as AnyObject,
                                           WSRequestParams.firstName: txtFirstName.text as AnyObject,
                                           WSRequestParams.lastName: txtLastName.text as AnyObject,
                                           WSRequestParams.label: [labelId] as AnyObject,
                                           WSRequestParams.birthday: self.birthday as AnyObject,
                                           WSRequestParams.email: txtEmail.text as AnyObject,
                                           WSRequestParams.mobile: mobile as AnyObject,
                                           WSRequestParams.note: notes as AnyObject]
        WSManager.wsCallEditBirthday(params, birthdayId) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                if self.recent != nil {
                    self.recent?.firstName = self.txtFirstName.text ?? ""
                    self.recent?.lastName = self.txtLastName.text ?? ""
                    self.recent?.birthDate = Helper.convertCurrentBirthDate(self.birthday)
                    self.recent?.email = self.txtEmail.text ?? ""
                    self.recent?.mobile = mobile.replacingOccurrences(of: "+", with: "")
                    self.recent?.label[0].id = self.labelId
                    self.recent?.label[0].labelColor = self.labelColor
                    self.recent?.label[0].labelName = self.labelName
                    self.recent?.note = self.notes
                    self.recent?.image = Helper.convertBase64Image(self.imageData)
                }
                else {
                    self.userBirthday?.firstName = self.txtFirstName.text ?? ""
                    self.userBirthday?.lastName = self.txtLastName.text ?? ""
                    self.userBirthday?.birthDate = Helper.convertCurrentBirthDate(self.birthday)
                    self.userBirthday?.email = self.txtEmail.text ?? ""
                    self.userBirthday?.mobile = mobile.replacingOccurrences(of: "+", with: "")
                    self.userBirthday?.label[0].id = self.labelId
                    self.userBirthday?.label[0].labelColor = self.labelColor
                    self.userBirthday?.label[0].labelName = self.labelName
                    self.userBirthday?.note = self.notes
                    self.userBirthday?.image = Helper.convertBase64Image(self.imageData)
                }
                
                LocalSettings.clearIsEditBirthday()
                userProfileNotAvailableDelegate?.updateBirthdayDetails()
                labelsViewControllerDelegate?.refreshLabels()
                homeViewControllerDelegate?.refreshData()
                
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func setBirthdayData() {
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = UIImage(named: "ic_pick")
                return
            }
            else {
                if let imageUrl = imageURL {
                    do {
                        self.imageData = try Data.init(contentsOf: imageUrl)
                        
                        if image?.size == CGSize(width: 128, height: 128) || image?.size == CGSize(width: 512, height: 512) {
                            self.isUserUpdatedImage = false
                            self.btnPhoto.setTitle(Strings.UPLOAD_PHOTO, for: UIControl.State())
                        }
                        else {
                            self.isUserUpdatedImage = true
                            self.btnPhoto.setTitle(Strings.CHANGE_PHOTO, for: UIControl.State())
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }

        if let url = URL(string: self.userBirthday?.image ?? "") {
            self.imgProfile.sd_setImage(with: url, completed: block)
        }

        self.txtFirstName.text = self.userBirthday?.firstName
        self.txtLastName.text = self.userBirthday?.lastName
        self.btnAddLabel.setTitle(labelName, for: UIControl.State())
        
        picker.isEdit = true
        
        if (self.userBirthday?.birthDate.count ?? 0) > 5 {
            self.swtYear.isOn = true
            self.picker.isYearHidden = false
            self.picker.isYearEmbedded = true
            let month = String(self.userBirthday?.birthDate.dropLast(3) ?? "0")
            self.picker.year = Int(String(self.userBirthday?.birthDate.dropLast(6) ?? "0")) ?? 0
            self.picker.month = Int(String(month.dropFirst(5))) ?? 0
            self.picker.date = Int(String(self.userBirthday?.birthDate.dropFirst(8) ?? "0")) ?? 0
            self.birthday = Helper.convertedDateMonthYear(self.userBirthday?.birthDate ?? "")
            self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
        }
        else {
            self.swtYear.isOn = false
            self.picker.isYearHidden = true
            self.picker.isYearEmbedded = false
            self.picker.month = Int(String(self.userBirthday?.birthDate.dropLast(3) ?? "0")) ?? 0
            self.picker.date = Int(String(self.userBirthday?.birthDate.dropFirst(3) ?? "0")) ?? 0
            self.birthday = Helper.convertedDateMonth(self.userBirthday?.birthDate ?? "")
            self.btnAddBirthday.setTitle(Helper.dateMonth(self.birthday), for: UIControl.State())
        }
        
        if !(self.userBirthday?.mobile.isEmpty ?? false) {
            if self.userBirthday?.mobile.starts(with: "0") ?? false {
                self.mobileStartsWithZero(self.userBirthday?.mobile ?? "")
            }
            else {
                self.parseNumber("+\(self.userBirthday?.mobile ?? "")")
            }
        }
        
        self.txtEmail.text = self.userBirthday?.email ?? ""
        self.notes = self.userBirthday?.note ?? ""
        
        if self.notes.isEmpty || self.notes == "" {
            self.btnAddNote.setTitle(Strings.ADD, for: UIControl.State())
        }
        else {
            self.btnAddNote.setTitle(Strings.EDIT, for: UIControl.State())
        }
    }
    
    func setRecentData() {
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = UIImage(named: "ic_pick")
                return
            }
            else {
                if let imageUrl = imageURL {
                    do {
                        self.imageData = try Data.init(contentsOf: imageUrl)
                        
                        if image?.size == CGSize(width: 128, height: 128) || image?.size == CGSize(width: 512, height: 512) {
                            self.isUserUpdatedImage = false
                            self.btnPhoto.setTitle(Strings.UPLOAD_PHOTO, for: UIControl.State())
                        }
                        else {
                            self.isUserUpdatedImage = true
                            self.btnPhoto.setTitle(Strings.CHANGE_PHOTO, for: UIControl.State())
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }

        if let url = URL(string: self.recent?.image ?? "") {
            self.imgProfile.sd_setImage(with: url, completed: block)
        }

        self.txtFirstName.text = self.recent?.firstName
        self.txtLastName.text = self.recent?.lastName
        self.btnAddLabel.setTitle(labelName, for: UIControl.State())
        
        picker.isEdit = true
        
        if (self.recent?.birthDate.count ?? 0) > 5 {
            self.swtYear.isOn = true
            self.picker.isYearHidden = false
            self.picker.isYearEmbedded = true
            let month = String(self.recent?.birthDate.dropLast(3) ?? "0")
            self.picker.year = Int(String(self.recent?.birthDate.dropLast(6) ?? "0")) ?? 0
            self.picker.month = Int(String(month.dropFirst(5))) ?? 0
            self.picker.date = Int(String(self.recent?.birthDate.dropFirst(8) ?? "0")) ?? 0
            self.birthday = Helper.convertedDateMonthYear(self.recent?.birthDate ?? "")
            self.btnAddBirthday.setTitle(Helper.dateMonthYear(self.birthday), for: UIControl.State())
        }
        else {
            self.swtYear.isOn = false
            self.picker.isYearHidden = true
            self.picker.isYearEmbedded = false
            self.picker.month = Int(String(self.recent?.birthDate.dropLast(3) ?? "0")) ?? 0
            self.picker.date = Int(String(self.recent?.birthDate.dropFirst(3) ?? "0")) ?? 0
            self.birthday = Helper.convertedDateMonth(self.recent?.birthDate ?? "")
            self.btnAddBirthday.setTitle(Helper.dateMonth(self.birthday), for: UIControl.State())
        }
        
        if !(self.recent?.mobile.isEmpty ?? false) {
            if self.recent?.mobile.starts(with: "0") ?? false {
                self.mobileStartsWithZero(self.recent?.mobile ?? "")
            }
            else {
                self.parseNumber("+\(self.recent?.mobile ?? "")")
            }
        }
        
        self.txtEmail.text = self.recent?.email ?? ""
        self.notes = self.recent?.note ?? ""
        
        if self.notes.isEmpty || self.notes == "" {
            self.btnAddNote.setTitle(Strings.ADD, for: UIControl.State())
        }
        else {
            self.btnAddNote.setTitle(Strings.EDIT, for: UIControl.State())
        }
    }
}
