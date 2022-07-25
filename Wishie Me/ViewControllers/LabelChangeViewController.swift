import UIKit
import SDWebImage

class LabelChangeViewController: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var userBirthday: Birthdays?
    var recent: RECENT?
    var labels = [Labels]()
    var imageData: Data?
    var labelId = 0
    var labelColor = ""
    var rightBarButton = UIBarButtonItem()
    
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

        setupBarButtons()
        setupImage()
        
        Helper.showLoader(onVC: self)
        fetchLabels()
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
            }
        }
    }
    
    func setupBarButtons() {
        let name = recent != nil ? ("\(recent?.firstName ?? "") \(recent?.lastName ?? "")") : ("\(userBirthday?.firstName ?? "") \(userBirthday?.lastName ?? "")")
        self.title = name
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        backButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = backButton
        
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
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
    
    func setupImage() {
        labelId = recent != nil ? recent?.label[0].id ?? 0: userBirthday?.label[0].id ?? 0
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = Helper.birthdayImage(self.recent != nil ? self.recent?.firstName ?? "" : self.userBirthday?.firstName ?? "")
                return
            }
        }
        
        if let url = URL(string: recent != nil ? recent?.image ?? "" : userBirthday?.image ?? "") {
            do {
                self.imageData = try Data.init(contentsOf: url)
            }
            catch let error {
                print(error.localizedDescription)
            }
            self.imgProfile.sd_setImage(with: url, completed: block)
        }
        else {
            self.imgProfile.image = Helper.birthdayImage(self.recent != nil ? self.recent?.firstName ?? "" : self.userBirthday?.firstName ?? "")
        }
    }
}

// MARK: - UIBUTTON ACTIONS
extension LabelChangeViewController {
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        //let selectedLabelId = recent != nil ? recent?.label[0].id ?? 0 : userBirthday?.label[0].id ?? 0
        if labelId > 0 { //labelId > 0 && labelId != selectedLabelId
            Helper.showLoader(onVC: self)
            self.editBirthday()
        }
        else {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.CHOOSE_LABEL)
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension LabelChangeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.ChooseLabelCell, for: indexPath) as! ChooseLabelCell
        
        let dict = labels[indexPath.row]
        
        cell.lblName.text = dict.labelName
        cell.imgLabel.tintColor = UIColor.init(hex: dict.labelColor.replacingOccurrences(of: "#", with: ""))
        
        if labelId == dict.id {
            cell.imgSelection.image = #imageLiteral(resourceName: "ic_selected")
        }
        else {
            cell.imgSelection.image = #imageLiteral(resourceName: "ic_unselected")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = labels[indexPath.row]
        labelId = dict.id
        labelColor = dict.labelColor
        rightBarButton.tintColor = WishieMeColors.greenColor
        
        self.tableView.reloadData()
    }
}

// MARK: - API CALL
extension LabelChangeViewController {
    func fetchLabels() {
        WSManager.wsCallGetLabels { (isSuccess, message, response) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                self.labels = response ?? []
                self.settings?.labels = response ?? []
                self.tableView.reloadData()
            }
            else {
                self.labels = self.settings?.labels ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func editBirthday() {
        var birthday = ""
        if (recent != nil ? recent?.birthDate.count ?? 0 : userBirthday?.birthDate.count ?? 0) > 5 {
            birthday = Helper.convertedDateMonthYear(recent != nil ? recent?.birthDate ?? "": userBirthday?.birthDate ?? "")
        }
        else {
            birthday = Helper.convertedDateMonth(recent != nil ? recent?.birthDate ?? "": userBirthday?.birthDate ?? "")
        }
        
        let firstName = recent != nil ? recent?.firstName : userBirthday?.firstName
        let lastName = recent != nil ? recent?.lastName : userBirthday?.lastName
        let email = recent != nil ? recent?.email : userBirthday?.email
        let mobile = recent != nil ? recent?.mobile : userBirthday?.mobile
        let note = recent != nil ? recent?.note : userBirthday?.note
        
        let params: [String: AnyObject] = [WSRequestParams.image: Helper.convertBase64Image(imageData) as AnyObject,
                                           WSRequestParams.firstName: firstName as AnyObject,
                                           WSRequestParams.lastName: lastName as AnyObject,
                                           WSRequestParams.label: [labelId] as AnyObject,
                                           WSRequestParams.birthday: birthday as AnyObject,
                                           WSRequestParams.email: email as AnyObject,
                                           WSRequestParams.mobile: mobile as AnyObject,
                                           WSRequestParams.note: note as AnyObject]
        WSManager.wsCallEditBirthday(params, userBirthday?.id ?? 0) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                if self.recent != nil {
                    self.recent?.label[0].id = self.labelId
                    self.recent?.label[0].labelColor = self.labelColor
                }
                else if self.userBirthday != nil {
                    self.userBirthday?.label[0].id = self.labelId
                    self.userBirthday?.label[0].labelColor = self.labelColor
                }
                friendProfileViewControllerDelegate?.updateLabel()
                userProfileNotAvailableDelegate?.updateBirthdayDetails()
                labelsViewControllerDelegate?.refreshLabels()
                homeViewControllerDelegate?.refreshData()

                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
