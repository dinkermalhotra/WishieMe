import UIKit
import Foundation
import Contacts
import SDWebImage

protocol HomeViewControllerDelegate {
    func refreshData()
    func refreshLabels()
    func sendToFriendRequest()
}

var homeViewControllerDelegate: HomeViewControllerDelegate?

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    
    var birthday: [(String, [Birthdays])] = []
    var filteredBirthday: [(String, [Birthdays])] = []
    var birthdays = [Birthdays]()
    var birthdaysByName = [Birthdays]()
    var isSortByName = false
    var labels = [Labels]()
    var recent = [RECENT]()
    var contacts = [FetchedContact]()
    var filterData = [FetchedContact]()
    var filteredBirthdays = [Birthdays]()
    var storedOffsets = [Int: CGFloat]()
    var selectedLabel: [String] = []
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
    
    var today = [Birthdays]()
    var tomorrow = [Birthdays]()
    var laterThisWeek = [Birthdays]()
    var nextWeek = [Birthdays]()
    var laterThisMonth = [Birthdays]()
    
    var january2021 = [Birthdays]()
    var february2021 = [Birthdays]()
    var march2021 = [Birthdays]()
    var april2021 = [Birthdays]()
    var may2021 = [Birthdays]()
    var june2021 = [Birthdays]()
    var july2021 = [Birthdays]()
    var august2021 = [Birthdays]()
    var september2021 = [Birthdays]()
    var october2021 = [Birthdays]()
    var november2021 = [Birthdays]()
    var december2021 = [Birthdays]()
    var january2022 = [Birthdays]()
    var february2022 = [Birthdays]()
    var march2022 = [Birthdays]()
    var april2022 = [Birthdays]()
    var may2022 = [Birthdays]()
    var june2022 = [Birthdays]()
    var july2022 = [Birthdays]()
    var august2022 = [Birthdays]()
    var september2022 = [Birthdays]()
    var october2022 = [Birthdays]()
    var november2022 = [Birthdays]()
    var december2022 = [Birthdays]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage.init(named: "ic_text_header")
        let imageView = UIImageView.init(image: image)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        setupNavigationBar()
        setupNotificationManager()
        
        homeViewControllerDelegate = self
        searchView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(searchViewTapped(_:))))
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: AppConstants.PORTRAIT_SCREEN_WIDTH, height: 56))
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        Helper.showLoader(onVC: self)
        fetchContacts()
        fetchBirthdays()
        fetchLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settings?.lastTabIndex = 0
        
        if UserData.homeViewType == Strings.NAME {
            highlightedNameButton()
        }
        else {
            highlightedDateButton()
        }
        
        if !searchView.isHidden {
            searchBar.becomeFirstResponder()
        }
    }
    
    func setupNavigationBar() {
        if headerViewTopConstraint.constant == 0 {
            let filterButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_filter_selected"), style: .plain, target: self, action: #selector(filterClicked(_:)))
            self.navigationItem.leftBarButtonItem = filterButton
        }
        else {
            let filterButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_filter_unselected"), style: .plain, target: self, action: #selector(filterClicked(_:)))
            self.navigationItem.leftBarButtonItem = filterButton
        }
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_calendar_unselected"), style: .plain, target: self, action: #selector(calendarClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendToDraft(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SEND_TO_DRAFT), object: nil)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.recent = []
        self.birthday = []
        self.birthdays = []
        self.filteredBirthday = []
        self.birthdaysByName = []
        self.filteredBirthdays = []
        self.labels = []
        self.contacts = []
        self.filterData = []
        
        hideFilter()
        setupNavigationBar()
        
        fetchContacts()
        fetchBirthdays()
        fetchLabels()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.searchViewBottomConstraint.constant = 0
        } else {
            self.searchViewBottomConstraint.constant = keyboardViewEndFrame.height
        }
    }
    
    private func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactImageDataAvailableKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = .userDefault
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        var image = Data()
                        if contact.imageDataAvailable {
                            image = contact.imageData ?? Data()
                        }
                        else {
                            let profileImage = Helper.birthdayImage(contact.givenName)
                            image = profileImage.pngData() ?? Data()
                        }
                        
                        if contact.phoneNumbers.first?.value.stringValue != nil {
                            self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? "", image: image))
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.filterData = self.contacts
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    func showSearchBar() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.searchViewTopConstraint.constant = 0
            self.searchBar.becomeFirstResponder()
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            self.searchView.isHidden = false
            self.searchTableView.isHidden = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    func hideSearchBar() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.searchViewTopConstraint.constant = -60
            self.searchBar.resignFirstResponder()
            self.setupNavigationBar()
            self.searchView.isHidden = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.searchBar.text = ""
            self.contacts = self.filterData
            self.filteredBirthdays = self.birthdays
        }
    }
    
    func showFilter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.headerViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    func hideFilter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.headerViewTopConstraint.constant = -44
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.selectedLabel = []
            self.sortView.isHidden = true
            self.filterView.isHidden = false
        }
    }
    
    func sortByName() {
        UserData.homeViewType = Strings.NAME
        isSortByName = true
        highlightedNameButton()
        filterBirthdays()
    }
    
    func sortByDate() {
        UserData.homeViewType = Strings.DATE
        isSortByName = false
        highlightedDateButton()
        filterBirthdays()
    }
    
    func highlightedNameButton() {
        btnName.setTitleColor(UIColor.white, for: UIControl.State())
        btnName.backgroundColor = WishieMeColors.greenColor
        
        btnDate.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        btnDate.backgroundColor = WishieMeColors.greenColor.withAlphaComponent(0.3)
    }
    
    func highlightedDateButton() {
        btnDate.setTitleColor(UIColor.white, for: UIControl.State())
        btnDate.backgroundColor = WishieMeColors.greenColor
        
        btnName.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        btnName.backgroundColor = WishieMeColors.greenColor.withAlphaComponent(0.3)
    }
    
    func addNewBirthday() {
        if let vc = ViewControllerHelper.getViewController(ofType: .CreateBirthdayViewController) as? CreateBirthdayViewController {
            let navigationController = UINavigationController.init(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.tintColor = WishieMeColors.greenColor
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func sendWishie() {
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc func sendToDraft(_ notification: Notification) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SavedWishieViewController) as? SavedWishieViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func inviteFriends() {
        if let vc = ViewControllerHelper.getViewController(ofType: .InviteFriendsViewController) as? InviteFriendsViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createNewLabel() {
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelsCreateViewController) as? LabelsCreateViewController {
            vc.isFromHome = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func filterBirthdays() {
        if isSortByName {
            if selectedLabel.count > 0 {
                var filtered = [Birthdays]()
                
                for selected in selectedLabel {
                    for birthday in birthdaysByName {
                        if selected == birthday.label[0].labelName {
                            filtered.append(birthday)
                        }
                    }
                }
                
                self.birthdaysByName = filtered.sorted(by: { (obj1, obj2) -> Bool in
                    let name1 = "\(obj1.firstName) \(obj1.lastName)"
                    let name2 = "\(obj2.firstName) \(obj2.lastName)"

                    return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
                })
            }
        }
        else {
            if selectedLabel.count > 0 {
                var filter = [Birthdays]()
                var filtered: [(String, [Birthdays])] = []
                
                self.emptyAllFilteredBirthdays()
                
                for selected in selectedLabel {
                    for (key, value) in birthday {
                        for newValue in value {
                            if selected == newValue.label[0].labelName {
                                filter.append(newValue)
                            }
                        }
                        
                        if filter.count > 0 {
                            let found = filtered.filter({$0.0.contains(key)})

                            if !found.isEmpty {
                                for (filteredKey, filteredValue) in filtered {
                                    if filteredKey.contains(key) {
                                        for newValue in filteredValue {
                                            filter.append(newValue)
                                        }
                                    }
                                }
                                sortFilterBirthdayByDate(filter)
                                filter = []
                            }
                            else {
                                sortFilterBirthdayByDate(filter)
                                filter = []
                            }
                        }
                    }
                }
                
                filtered = self.filteredReturn()
                birthday = filtered
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func searchViewTapped(_ sender: UITapGestureRecognizer) {
        if searchBar.text?.isEmpty ?? true {
            self.view.endEditing(true)
            hideSearchBar()
        }
    }
    
    @IBAction func filterClicked(_ sender: UIBarButtonItem) {
        if sender.image == UIImage.init(named: "ic_filter_unselected") {
            sender.image = #imageLiteral(resourceName: "ic_filter_selected")
            showFilter()
        }
        else {
            sender.image = #imageLiteral(resourceName: "ic_filter_unselected")
            hideFilter()
        }
        
        self.birthday = self.filteredBirthday
        self.birthdaysByName = self.filteredBirthdays
        self.tableView.reloadData()
        self.filterCollectionView.reloadData()
        self.emptyAllFilteredBirthdays()
    }
    
    func emptyAllFilteredBirthdays() {
        today = []
        tomorrow = []
        laterThisWeek = []
        nextWeek = []
        laterThisMonth = []
        
        january2021 = []
        february2021 = []
        march2021 = []
        april2021 = []
        may2021 = []
        june2021 = []
        july2021 = []
        august2021 = []
        september2021 = []
        october2021 = []
        november2021 = []
        december2021 = []
        january2022 = []
        february2022 = []
        march2022 = []
        april2022 = []
        may2022 = []
        june2022 = []
        july2022 = []
        august2022 = []
        september2022 = []
        october2022 = []
        november2022 = []
        december2022 = []
    }
    
    @IBAction func calendarClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .CalendarViewController) as? CalendarViewController {
            vc.birthdays = self.birthdays
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func searchClicked(_ sender: UIButton) {
        showSearchBar()
    }
    
    @IBAction func addClicked(_ sender: UIButton) {
        hideFilter()
        setupNavigationBar()
        Helper.showThreeWishieOptionActionAlert(onVC: self, title: nil, titleOne: Strings.ADD_NEW_BIRTHDAY, actionOne: addNewBirthday, titleTwo: Strings.INVITE_FRIENDS, actionTwo: inviteFriends, titleThree: Strings.CREATE_NEW_LABEL, actionThree: createNewLabel, actionCancel: {
            
        }, styleType: .default)
//        Helper.showFourOptionsActionAlert(onVC: self, title: nil, titleOne: Strings.ADD_NEW_BIRTHDAY, actionOne: addNewBirthday, titleTwo: Strings.SEND_A_WISHIE, actionTwo: sendWishie, titleThree: Strings.INVITE_FRIENDS, actionThree: inviteFriends, titleFour: Strings.CREATE_NEW_LABEL, actionFour: createNewLabel, styleType: .default)
    }
    
    @IBAction func sortClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            self.sortView.isHidden = false
            self.filterView.isHidden = true
        }
        else {
            self.sortView.isHidden = true
            self.filterView.isHidden = false
        }
    }
    
    @IBAction func sortByNameClicked(_ sender: UIButton) {
        sortByName()
    }
    
    @IBAction func sortByDateClicked(_ sender: UIButton) {
        sortByDate()
    }
    
    @IBAction func crossClicked(_ sender: UIButton) {
        hideFilter()
        setupNavigationBar()
    }
}

// MARK: - SEARCHCONTROLLER
extension HomeViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideFilter()
        setupNavigationBar()
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchTableView.isHidden = true
            
            self.contacts = self.filterData
            self.filteredBirthdays = self.birthdays
            self.searchTableView.reloadData()
        }
        else {
            self.searchTableView.isHidden = false
            
            self.contacts = filterData.filter {
//                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
//                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
                let name = "\($0.firstName) \($0.lastName)"
                return name.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }
            
            for birthday in self.birthdays {
                self.contacts = self.contacts.filter {
                    String($0.telephone.suffix(8)) != String(birthday.mobile.suffix(8))
                }
            }
            
            self.filteredBirthdays = birthdays.filter {
//                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
//                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                let name = "\($0.firstName) \($0.lastName)"
                return name.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }
            
            self.searchTableView.reloadData()
        }
    }
}

//// MARK: - SCROLLVIEWDELEGATE
//extension HomeViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if searchView.isHidden && headerViewTopConstraint.constant == -44 {
//            if scrollView.contentOffset.y <= -160 {
//                showSearchBar()
//            }
//        }
//    }
//}

// MARK: - UITABLEVIEW METHODS
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.searchTableView {
            if self.filteredBirthdays.count > 0 {
                return 2
            }
            else {
                return 1
            }
        }
        else {
            if isSortByName {
                return 2
            }
            else {
                return 1 + self.birthday.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchTableView {
            if self.filteredBirthdays.count > 0 && section == 0 {
                return self.filteredBirthdays.count
            }
            else {
                return self.contacts.count
            }
        }
        else {
            if section == 0 {
                return 1
            }
            else {
                if isSortByName {
                    return self.birthdaysByName.count
                }
                else {
                    let value = self.birthday[section - 1]
                    return value.1.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.searchTableView {
            if self.filteredBirthdays.count > 0 && filteredBirthdays.count > indexPath.row {
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeCell, for: indexPath) as! HomeCell
                    
                    let value = self.filteredBirthdays[indexPath.row]

                    let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                        //print(image)
                        if (image == nil) {
                            cell.imgProfile.image = Helper.birthdayImage(value.firstName)
                            return
                        }
                    }

                    if let url = URL(string: value.image) {
                        cell.imgProfile.sd_setImage(with: url, completed: block)
                    }
                    else {
                        cell.imgProfile.image = Helper.birthdayImage(value.firstName)
                    }

                    cell.lblName.text = "\(value.firstName ) \(value.lastName)"
                    cell.lblDaysLeft.text = "\(value.daysLeft )"

                    var date = value.birthDate
                    var birthdate = value.birthDate

                    if date.count > 5 {
                        date = Helper.shortDateYear(date)
                    }
                    else {
                        date = Helper.shortDate(date)
                    }

                    if let turned = value.turnedAge {
                        if birthdate.count > 5 {
                            birthdate = String(birthdate.dropFirst(5))
                        }

                        if birthdate == Helper.tomorrowDate() {
                            cell.lblDays.text = Strings.DAY
                        }
                        else {
                            cell.lblDays.text = Strings.DAYS
                        }

                        if birthdate == Helper.todayDate() {
                            cell.viewParty.isHidden = false
                            cell.lblAge.text = "\(date) • \(Strings.TURNED) \(turned)"
                        }
                        else {
                            cell.viewParty.isHidden = true
                            cell.lblAge.text = "\(date) • \(Strings.TURNING) \(turned  + 1)"
                        }
                    }
                    else {
                        if birthdate == Helper.tomorrowDate() {
                            cell.lblDays.text = Strings.DAY
                        }
                        else {
                            cell.lblDays.text = Strings.DAYS
                        }
                        
                        if birthdate == Helper.todayDate() {
                            cell.viewParty.isHidden = false
                            cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                        }
                        else {
                            cell.viewParty.isHidden = true
                            cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                        }
                    }
                    
                    cell.accessoryType = .disclosureIndicator
                    cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
                    
                    let tap = UITapGestureRecognizer.init(target: self, action: #selector(cellSelected(_:)))
                    cell.tag = indexPath.section
                    cell.accessibilityValue = "\(indexPath.row)"
                    cell.addGestureRecognizer(tap)
                    
                    return cell
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.SearchCell, for: indexPath) as! SearchCell
            
            cell.lblName.text = "\(contacts[indexPath.row].firstName) \(contacts[indexPath.row].lastName)"
            cell.imgProfile.image = UIImage.init(data: contacts[indexPath.row].image)
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(cellSelected(_:)))
            cell.tag = indexPath.section
            cell.accessibilityValue = "\(indexPath.row)"
            cell.addGestureRecognizer(tap)
            
            return cell
        }
        else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeRecentCell, for: indexPath) as! HomeRecentCell
                
                if self.recent.count > 0 {
                    cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                    cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
                }
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeCell, for: indexPath) as! HomeCell
                
                var value: Birthdays?
                
                if isSortByName {
                    value = self.birthdaysByName[indexPath.row]
                }
                else {
                    let key = self.birthday[indexPath.section - 1]
                    let dict = key.1
                    value = dict[indexPath.row]
                }

                let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                    //print(image)
                    if (image == nil) {
                        cell.imgProfile.image = Helper.birthdayImage(value?.firstName ?? "")
                        return
                    }
                }
                
                if value?.friend != nil {
                    cell.imgProfile.layer.borderWidth = 1.0
                    cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
                }
                else {
                    cell.imgProfile.layer.borderWidth = 0
                    cell.imgProfile.layer.borderColor = nil
                }

                if let url = URL(string: value?.image ?? "") {
                    cell.imgProfile.sd_setImage(with: url, completed: block)
                }
                else {
                    cell.imgProfile.image = Helper.birthdayImage(value?.firstName ?? "")
                }

                cell.lblName.text = "\(value?.firstName ?? "") \(value?.lastName ?? "")"
                cell.lblDaysLeft.text = "\(value?.daysLeft ?? 0)"

                var date = value?.birthDate ?? ""
                var birthdate = value?.birthDate ?? ""
                
                if date.count > 5 {
                    date = Helper.shortDateYear(date)
                }
                else {
                    date = Helper.shortDate(date)
                }
                
                if let turned = value?.turnedAge {
                    if birthdate.count > 5 {
                        birthdate = String(birthdate.dropFirst(5))
                    }
                    
                    if birthdate == Helper.tomorrowDate() {
                        cell.lblDays.text = Strings.DAY
                    }
                    else {
                        cell.lblDays.text = Strings.DAYS
                    }
                    
                    if birthdate == Helper.todayDate() {
                        cell.viewParty.isHidden = false
                        cell.lblAge.text = "\(date) • \(Strings.TURNED) \(turned)"
                    }
                    else {
                        cell.viewParty.isHidden = true
                        cell.lblAge.text = "\(date) • \(Strings.TURNING) \(turned  + 1)"
                    }
                }
                else {
                    if birthdate == Helper.tomorrowDate() {
                        cell.lblDays.text = Strings.DAY
                    }
                    else {
                        cell.lblDays.text = Strings.DAYS
                    }
                    
                    if birthdate == Helper.todayDate() {
                        cell.viewParty.isHidden = false
                        cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                    }
                    else {
                        cell.viewParty.isHidden = true
                        cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                    }
                }
                
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
                
                return cell
            }
        }
    }
    
    @objc func cellSelected(_ sender: UITapGestureRecognizer) {
        if filteredBirthdays.count > 0 && sender.view?.tag == 0 {
            self.view.endEditing(true)
            let row = Int(sender.view?.accessibilityValue ?? "")
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                vc.userBirthday = filteredBirthdays[row ?? 0]
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        else {
            let row = Int(sender.view?.accessibilityValue ?? "")
            if let vc = ViewControllerHelper.getViewController(ofType: .CreateBirthdayViewController) as? CreateBirthdayViewController {
                vc.firstName = contacts[row ?? 0].firstName
                vc.lastName = contacts[row ?? 0].lastName
                vc.mobileNumber = contacts[row ?? 0].telephone
                vc.imageData = contacts[row ?? 0].image
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var value: Birthdays?
        if isSortByName {
            value = self.birthdaysByName[indexPath.row]
        }
        else {
            if indexPath.section != 0 {
                let key = self.birthday[indexPath.section - 1]
                let dict = key.1
                value = dict[indexPath.row]
            }
        }
        
        if value?.friend != nil {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                vc.userBirthday = value
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                vc.userBirthday = value
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.searchTableView {
            return false
        }
        else {
            if indexPath.section == 0 {
                return false
            }
            else {
                return true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var value: Birthdays?
        if isSortByName {
            value = self.birthdaysByName[indexPath.row]
        }
        else {
            let key = self.birthday[indexPath.section - 1]
            let dict = key.1
            value = dict[indexPath.row]
        }
        
        if value?.friend != nil {
            let changeLabel = UIContextualAction.init(style: .normal, title: Strings.CHANGE_LABEL, handler: { (action, view, handler) in
                self.hideFilter()
                self.setupNavigationBar()
                
                self.tableView.setEditing(false, animated: true)
                
                if let vc = ViewControllerHelper.getViewController(ofType: .LabelChangeViewController) as? LabelChangeViewController {
                    vc.userBirthday = value
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            changeLabel.image = UISwipeActionsConfiguration.makeTitledImage(image: #imageLiteral(resourceName: "ic_label_unselected"), title: Strings.CHANGE_LABEL)
            
            let configuration = UISwipeActionsConfiguration(actions: [changeLabel])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        else {
            let edit = UIContextualAction.init(style: .normal, title: Strings.EDIT, handler: { (action, view, handler) in
                self.hideFilter()
                self.setupNavigationBar()
                
                if let vc = ViewControllerHelper.getViewController(ofType: .CreateBirthdayViewController) as? CreateBirthdayViewController {
                    LocalSettings.isEditBirthday = true
                    vc.userBirthday = value
                    for label in value?.label ?? [] {
                        vc.labelId = label.id
                        vc.labelName = label.labelName
                    }
                    let navigationController = UINavigationController.init(rootViewController: vc)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            })
            edit.image = UISwipeActionsConfiguration.makeTitledImage(image: #imageLiteral(resourceName: "ic_edit_comment"), title: Strings.EDIT)
            
            let delete = UIContextualAction.init(style: .normal, title: Strings.DELETE, handler: { (action, view, handler) in
                self.hideFilter()
                self.setupNavigationBar()
                
                self.tableView.setEditing(false, animated: true)
                
                Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.DELETE_BIRTHDAY, message: AlertMessages.DELETE_BIRTHDAY, btnOkTitle: Strings.DELETE, btnCancelTitle: Strings.CANCEL, onOk: {
                    Helper.showLoader(onVC: self)
                    self.deleteBirthday(value?.id ?? 0)
                })
            })
            delete.image = UISwipeActionsConfiguration.makeTitledImage(image: #imageLiteral(resourceName: "ic_delete_comment"), title: Strings.DELETE)
            delete.backgroundColor = UIColor.red
            
            let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? HomeRecentCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.searchTableView {
            if self.filteredBirthdays.count > 0 && section == 0 {
                return 0
            }
            return 20
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeHeaderCell) as! HomeHeaderCell
            
            cell.lblTitle.text = Strings.PHONE_CONTACTS_WITH_NO_EVENTS
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeHeaderCell) as! HomeHeaderCell
            
            if section == 0 {
                cell.lblTitle.text = Strings.RECENT
            }
            else {
                if isSortByName {
                    cell.lblTitle.text = Strings.EVENTS
                }
                else {
                    let key = self.birthday[section - 1]
                    let dict = key.0
                    cell.lblTitle.text = dict
                }
            }
            
            return cell
        }
    }
}

// MARK: - UICOLLECTIONVIEW METHODS
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.filterCollectionView {
            return labels.count
        }
        else {
            return recent.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.HomeFilterCollectionCell, for: indexPath) as! HomeFilterCollectionCell
            
            if selectedLabel.contains(labels[indexPath.row].labelName) {
                cell.lblLabel.textColor = UIColor.white
                cell.lblLabel.backgroundColor = WishieMeColors.greenColor
            } else {
                cell.lblLabel.textColor = WishieMeColors.greenColor
                cell.lblLabel.backgroundColor = WishieMeColors.greenColor.withAlphaComponent(0.3)
            }
            
            let value = self.labels[indexPath.row]
            cell.lblLabel.text = "\(value.labelName)    "
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.HomeRecentCollectionCell, for: indexPath) as! HomeRecentCollectionCell
            
            let value = self.recent[indexPath.row]
            
            DispatchQueue.main.async {
                if value.friend != nil {
                    cell.imgProfile.layer.borderWidth = 1.0
                    cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
                }
                else {
                    cell.imgProfile.layer.borderWidth = 0
                    cell.imgProfile.layer.borderColor = nil
                }
                
                cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height / 2
                cell.imgProfile.clipsToBounds = true
            }
            
            // IMAGE
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    cell.imgProfile.image = Helper.birthdayImage(value.firstName)
                    return
                }
            }
            
            if let url = URL(string: value.image) {
                cell.imgProfile.sd_setImage(with: url, completed: block)
            }
            else {
                cell.imgProfile.image = Helper.birthdayImage(value.firstName)
            }

            // NAME
            cell.lblname.text = value.firstName
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeFilterCollectionCell {
                if selectedLabel.contains(labels[indexPath.row].labelName) {
                    cell.lblLabel.textColor = WishieMeColors.greenColor
                    cell.lblLabel.backgroundColor = WishieMeColors.greenColor.withAlphaComponent(0.3)

                    self.birthdaysByName = self.filteredBirthdays
                    self.birthday = self.filteredBirthday

                    for i in 0..<selectedLabel.count {
                        if selectedLabel[i] == self.labels[indexPath.row].labelName {
                            self.selectedLabel.remove(at: i)
                            break
                        }
                    }
                    
                    self.filterBirthdays()
                }
                else {
                    cell.lblLabel.textColor = UIColor.white
                    cell.lblLabel.backgroundColor = WishieMeColors.greenColor

                    self.birthdaysByName = self.filteredBirthdays
                    self.birthday = self.filteredBirthday
                    self.selectedLabel.append(self.labels[indexPath.row].labelName)
                    self.filterBirthdays()
                }
            }
        }
        else {
            let value = self.recent[indexPath.row]
            
            if value.friend != nil {
                if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                    vc.recent = value
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                    vc.recent = value
                    let navigationController = UINavigationController.init(rootViewController: vc)
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - HomeViewControllerDelegate
extension HomeViewController: HomeViewControllerDelegate {
    func refreshData() {
        self.recent = []
        self.birthday = []
        self.birthdays = []
        self.filteredBirthday = []
        self.birthdaysByName = []
        self.filteredBirthdays = []
        
        fetchBirthdays()
    }
    
    func refreshLabels() {
        self.labels = []
        
        fetchLabels()
    }
    
    func sendToFriendRequest() {
        if let vc = ViewControllerHelper.getViewController(ofType: .FriendRequestViewController) as? FriendRequestViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - API CALL
extension HomeViewController {
    func fetchBirthdays() {
        WSManager.wsCallGetBirthday { (isSuccess, message, recent, birthdays)  in
            Helper.hideLoader(onVC: self)
            self.refreshControl.endRefreshing()
            
            if isSuccess {
                self.settings?.recents = recent
                self.settings?.birthdays = birthdays
                
                self.recent = recent ?? []
                self.filterBirthdayByDate(birthdays ?? [])
                self.filterBirthdayByName(birthdays ?? [])
            }
            else {
                if message == AlertMessages.NO_INTERNET {
                    Helper.showToast(onVC: self)
                }
                
                self.recent = self.settings?.recents ?? []
                self.filterBirthdayByDate(self.settings?.birthdays ?? [])
                self.filterBirthdayByName(self.settings?.birthdays ?? [])
            }
        }
    }
    
    func deleteBirthday(_ id: Int) {
        WSManager.wsCallDeleteBirthday(id) { (isSuccess, message) in
            if isSuccess {
                labelsViewControllerDelegate?.refreshLabels()
                self.refreshData()
            }
        }
    }
    
    func fetchLabels() {
        WSManager.wsCallGetLabels { (isSuccess, message, response) in
            if isSuccess {
                self.labels = response ?? []
                self.settings?.labels = response ?? []
                self.filterCollectionView.reloadData()
            }
            else {
                self.labels = self.settings?.labels ?? []
                self.filterCollectionView.reloadData()
            }
        }
    }
    
    func filterBirthdayByName(_ birthdays: [Birthdays]) {
        self.birthdaysByName = birthdays.sorted(by: { (obj1, obj2) -> Bool in
            let name1 = "\(obj1.firstName) \(obj1.lastName)"
            let name2 = "\(obj2.firstName) \(obj2.lastName)"

            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        })
        
        self.filteredBirthdays = self.birthdaysByName
        self.birthdays = self.birthdaysByName
    }
    
    func filterBirthdayByDate(_ birthdays: [Birthdays]) {
        var today = [Birthdays]()
        var tomorrow = [Birthdays]()
        var laterThisWeek = [Birthdays]()
        var nextWeek = [Birthdays]()
        var laterThisMonth = [Birthdays]()
        
        var january2021 = [Birthdays]()
        var february2021 = [Birthdays]()
        var march2021 = [Birthdays]()
        var april2021 = [Birthdays]()
        var may2021 = [Birthdays]()
        var june2021 = [Birthdays]()
        var july2021 = [Birthdays]()
        var august2021 = [Birthdays]()
        var september2021 = [Birthdays]()
        var october2021 = [Birthdays]()
        var november2021 = [Birthdays]()
        var december2021 = [Birthdays]()
        var january2022 = [Birthdays]()
        var february2022 = [Birthdays]()
        var march2022 = [Birthdays]()
        var april2022 = [Birthdays]()
        var may2022 = [Birthdays]()
        var june2022 = [Birthdays]()
        var july2022 = [Birthdays]()
        var august2022 = [Birthdays]()
        var september2022 = [Birthdays]()
        var october2022 = [Birthdays]()
        var november2022 = [Birthdays]()
        var december2022 = [Birthdays]()
        
        for birthday in birthdays {
            var birthDate = birthday.birthDate
            let birthDay = birthday.birthDay
            
            if birthDate.count > 5 {
                birthDate = String(birthDate.dropFirst(5))
            }
            
            if birthday.type == Strings.TODAY.lowercased() {
                today.append(birthday)
            }
            else if birthday.type == Strings.TOMORROW.lowercased() {
                tomorrow.append(birthday)
            }
            else if birthday.type == Strings.THIS_WEEK {
                laterThisWeek.append(birthday)
            }
            else if birthday.type == Strings.next_week {
                nextWeek.append(birthday)
            }
            else if birthday.type == Strings.THIS_MONTH {
                laterThisMonth.append(birthday)
            }
            else if birthDay == "January 2021" && String(birthDate.dropLast(3)) == "01" {
                january2021.append(birthday)
            }
            else if birthDay == "February 2021" && String(birthDate.dropLast(3)) == "02" {
                february2021.append(birthday)
            }
            else if birthDay == "March 2021" && String(birthDate.dropLast(3)) == "03" {
                march2021.append(birthday)
            }
            else if birthDay == "April 2021" && String(birthDate.dropLast(3)) == "04" {
                april2021.append(birthday)
            }
            else if birthDay == "May 2021" && String(birthDate.dropLast(3)) == "05" {
                may2021.append(birthday)
            }
            else if birthDay == "June 2021" && String(birthDate.dropLast(3)) == "06" {
                june2021.append(birthday)
            }
            else if birthDay == "July 2021" && String(birthDate.dropLast(3)) == "07" {
                july2021.append(birthday)
            }
            else if birthDay == "August 2021" && String(birthDate.dropLast(3)) == "08" {
                august2021.append(birthday)
            }
            else if birthDay == "September 2021" && String(birthDate.dropLast(3)) == "09" {
                september2021.append(birthday)
            }
            else if birthDay == "October 2021" && String(birthDate.dropLast(3)) == "10" {
                october2021.append(birthday)
            }
            else if birthDay == "November 2021" && String(birthDate.dropLast(3)) == "11" {
                november2021.append(birthday)
            }
            else if birthDay == "December 2021" && String(birthDate.dropLast(3)) == "12" {
                december2021.append(birthday)
            }
            else if birthDay == "January 2022" && String(birthDate.dropLast(3)) == "01" {
                january2022.append(birthday)
            }
            else if birthDay == "February 2022" && String(birthDate.dropLast(3)) == "02" {
                february2022.append(birthday)
            }
            else if birthDay == "March 2022" && String(birthDate.dropLast(3)) == "03" {
                march2022.append(birthday)
            }
            else if birthDay == "April 2022" && String(birthDate.dropLast(3)) == "04" {
                april2022.append(birthday)
            }
            else if birthDay == "May 2022" && String(birthDate.dropLast(3)) == "05" {
                may2022.append(birthday)
            }
            else if birthDay == "June 2022" && String(birthDate.dropLast(3)) == "06" {
                june2022.append(birthday)
            }
            else if birthDay == "July 2022" && String(birthDate.dropLast(3)) == "07" {
                july2022.append(birthday)
            }
            else if birthDay == "August 2022" && String(birthDate.dropLast(3)) == "08" {
                august2022.append(birthday)
            }
            else if birthDay == "September 2022" && String(birthDate.dropLast(3)) == "09" {
                september2022.append(birthday)
            }
            else if birthDay == "October 2022" && String(birthDate.dropLast(3)) == "10" {
                october2022.append(birthday)
            }
            else if birthDay == "November 2022" && String(birthDate.dropLast(3)) == "11" {
                november2022.append(birthday)
            }
            else if birthDay == "December 2022" && String(birthDate.dropLast(3)) == "12" {
                december2022.append(birthday)
            }
        }
        
        if today.count > 0 {
            self.birthday.append((Strings.TODAY, today))
        }
        
        if tomorrow.count > 0 {
            self.birthday.append((Strings.TOMORROW, tomorrow))
        }
        
        if laterThisWeek.count > 0 {
            self.birthday.append((Strings.LATER_THIS_WEEK, laterThisWeek))
        }

        if nextWeek.count > 0 {
            self.birthday.append((Strings.NEXT_WEEK, nextWeek))
        }

        if laterThisMonth.count > 0 {
            self.birthday.append((Strings.LATER_THIS_MONTH, laterThisMonth))
        }

        if january2021.count > 0 {
            self.birthday.append(("JANUARY 2021", january2021))
        }

        if february2021.count > 0 {
            self.birthday.append(("FEBRUARY 2021", february2021))
        }

        if march2021.count > 0 {
            self.birthday.append(("MARCH 2021", march2021))
        }

        if april2021.count > 0 {
            self.birthday.append(("APRIL 2021", april2021))
        }

        if may2021.count > 0 {
            self.birthday.append(("MAY 2021", may2021))
        }

        if june2021.count > 0 {
            self.birthday.append(("JUNE 2021", june2021))
        }

        if july2021.count > 0 {
            self.birthday.append(("JULY 2021", july2021))
        }

        if august2021.count > 0 {
            self.birthday.append(("AUGUST 2021", august2021))
        }

        if september2021.count > 0 {
            self.birthday.append(("SEPTEMBER 2021", september2021))
        }

        if october2021.count > 0 {
            self.birthday.append(("OCTOBER 2021", october2021))
        }

        if november2021.count > 0 {
            self.birthday.append(("NOVEMBER 2021", november2021))
        }

        if december2021.count > 0 {
            self.birthday.append(("DECEMBER 2021", december2021))
        }
        
        if january2022.count > 0 {
            self.birthday.append(("JANUARY 2022", january2022))
        }
        
        if february2022.count > 0 {
            self.birthday.append(("FEBRUARY 2022", february2022))
        }
        
        if march2022.count > 0 {
            self.birthday.append(("MARCH 2022", march2022))
        }

        if april2022.count > 0 {
            self.birthday.append(("APRIL 2022", april2022))
        }

        if may2022.count > 0 {
            self.birthday.append(("MAY 2022", may2022))
        }

        if june2022.count > 0 {
            self.birthday.append(("JUNE 2022", june2022))
        }

        if july2022.count > 0 {
            self.birthday.append(("JULY 2022", july2022))
        }

        if august2022.count > 0 {
            self.birthday.append(("AUGUST 2022", august2022))
        }

        if september2022.count > 0 {
            self.birthday.append(("SEPTEMBER 2022", september2022))
        }

        if october2022.count > 0 {
            self.birthday.append(("OCTOBER 2022", october2022))
        }

        if november2022.count > 0 {
            self.birthday.append(("NOVEMBER 2022", november2022))
        }

        if december2022.count > 0 {
            self.birthday.append(("DECEMBER 2022", december2022))
        }
        
        self.filteredBirthday = self.birthday
        self.tableView.reloadData()
    }
    
    func sortFilterBirthdayByDate(_ birthdays: [Birthdays]) {
        for birthday in birthdays {
            var birthDate = birthday.birthDate
            let birthDay = birthday.birthDay
            
            if birthDate.count > 5 {
                birthDate = String(birthDate.dropFirst(5))
            }
            
            if birthday.type == Strings.TODAY.lowercased() {
                if !today.contains(where: {$0.id == birthday.id}) {
                    today.append(birthday)
                }
            }
            else if birthday.type == Strings.TOMORROW.lowercased() {
                if !tomorrow.contains(where: {$0.id == birthday.id}) {
                    tomorrow.append(birthday)
                }
            }
            else if birthday.type == Strings.THIS_WEEK {
                if !laterThisWeek.contains(where: {$0.id == birthday.id}) {
                    laterThisWeek.append(birthday)
                }
            }
            else if birthday.type == Strings.next_week {
                if !nextWeek.contains(where: {$0.id == birthday.id}) {
                    nextWeek.append(birthday)
                }
            }
            else if birthday.type == Strings.THIS_MONTH {
                if !laterThisMonth.contains(where: {$0.id == birthday.id}) {
                    laterThisMonth.append(birthday)
                }
            }
            else if birthDay == "January 2021" && String(birthDate.dropLast(3)) == "01" {
                if !january2021.contains(where: {$0.id == birthday.id}) {
                    january2021.append(birthday)
                }
            }
            else if birthDay == "February 2021" && String(birthDate.dropLast(3)) == "02" {
                if !february2021.contains(where: {$0.id == birthday.id}) {
                    february2021.append(birthday)
                }
            }
            else if birthDay == "March 2021" && String(birthDate.dropLast(3)) == "03" {
                if !march2021.contains(where: {$0.id == birthday.id}) {
                    march2021.append(birthday)
                }
            }
            else if birthDay == "April 2021" && String(birthDate.dropLast(3)) == "04" {
                if !april2021.contains(where: {$0.id == birthday.id}) {
                    april2021.append(birthday)
                }
            }
            else if birthDay == "May 2021" && String(birthDate.dropLast(3)) == "05" {
                if !may2021.contains(where: {$0.id == birthday.id}) {
                    may2021.append(birthday)
                }
            }
            else if birthDay == "June 2021" && String(birthDate.dropLast(3)) == "06" {
                if !june2021.contains(where: {$0.id == birthday.id}) {
                    june2021.append(birthday)
                }
            }
            else if birthDay == "July 2021" && String(birthDate.dropLast(3)) == "07" {
                if !july2021.contains(where: {$0.id == birthday.id}) {
                    july2021.append(birthday)
                }
            }
            else if birthDay == "August 2021" && String(birthDate.dropLast(3)) == "08" {
                if !august2021.contains(where: {$0.id == birthday.id}) {
                    august2021.append(birthday)
                }
            }
            else if birthDay == "September 2021" && String(birthDate.dropLast(3)) == "09" {
                if !september2021.contains(where: {$0.id == birthday.id}) {
                    september2021.append(birthday)
                }
            }
            else if birthDay == "October 2021" && String(birthDate.dropLast(3)) == "10" {
                if !october2021.contains(where: {$0.id == birthday.id}) {
                    october2021.append(birthday)
                }
            }
            else if birthDay == "November 2021" && String(birthDate.dropLast(3)) == "11" {
                if !november2021.contains(where: {$0.id == birthday.id}) {
                    november2021.append(birthday)
                }
            }
            else if birthDay == "December 2021" && String(birthDate.dropLast(3)) == "12" {
                if !december2021.contains(where: {$0.id == birthday.id}) {
                    december2021.append(birthday)
                }
            }
            else if birthDay == "January 2022" && String(birthDate.dropLast(3)) == "01" {
                if !january2022.contains(where: {$0.id == birthday.id}) {
                    january2022.append(birthday)
                }
            }
            else if birthDay == "February 2022" && String(birthDate.dropLast(3)) == "02" {
                if !february2022.contains(where: {$0.id == birthday.id}) {
                    february2022.append(birthday)
                }
            }
            else if birthDay == "March 2022" && String(birthDate.dropLast(3)) == "03" {
                if !march2022.contains(where: {$0.id == birthday.id}) {
                    march2022.append(birthday)
                }
            }
            else if birthDay == "April 2022" && String(birthDate.dropLast(3)) == "04" {
                if !april2022.contains(where: {$0.id == birthday.id}) {
                    april2022.append(birthday)
                }
            }
            else if birthDay == "May 2022" && String(birthDate.dropLast(3)) == "05" {
                if !may2022.contains(where: {$0.id == birthday.id}) {
                    may2022.append(birthday)
                }
            }
            else if birthDay == "June 2022" && String(birthDate.dropLast(3)) == "06" {
                if !june2022.contains(where: {$0.id == birthday.id}) {
                    june2022.append(birthday)
                }
            }
            else if birthDay == "July 2022" && String(birthDate.dropLast(3)) == "07" {
                if !july2022.contains(where: {$0.id == birthday.id}) {
                    july2022.append(birthday)
                }
            }
            else if birthDay == "August 2022" && String(birthDate.dropLast(3)) == "08" {
                if !august2022.contains(where: {$0.id == birthday.id}) {
                    august2022.append(birthday)
                }
            }
            else if birthDay == "September 2022" && String(birthDate.dropLast(3)) == "09" {
                if !september2022.contains(where: {$0.id == birthday.id}) {
                    september2022.append(birthday)
                }
            }
            else if birthDay == "October 2022" && String(birthDate.dropLast(3)) == "10" {
                if !october2022.contains(where: {$0.id == birthday.id}) {
                    october2022.append(birthday)
                }
            }
            else if birthDay == "November 2022" && String(birthDate.dropLast(3)) == "11" {
                if !november2022.contains(where: {$0.id == birthday.id}) {
                    november2022.append(birthday)
                }
            }
            else if birthDay == "December 2022" && String(birthDate.dropLast(3)) == "12" {
                if !december2022.contains(where: {$0.id == birthday.id}) {
                    december2022.append(birthday)
                }
            }
        }
    }
    
    func filteredReturn() -> [(String, [Birthdays])] {
        var filtered: [(String, [Birthdays])] = []
        
        if today.count > 0 {
            filtered.append((Strings.TODAY, today))
        }
        
        if tomorrow.count > 0 {
            filtered.append((Strings.TOMORROW, tomorrow))
        }
        
        if laterThisWeek.count > 0 {
            filtered.append((Strings.LATER_THIS_WEEK, laterThisWeek))
        }

        if nextWeek.count > 0 {
            filtered.append((Strings.NEXT_WEEK, nextWeek))
        }

        if laterThisMonth.count > 0 {
            filtered.append((Strings.LATER_THIS_MONTH, laterThisMonth))
        }

        if january2021.count > 0 {
            filtered.append(("JANUARY 2021", january2021))
        }

        if february2021.count > 0 {
            filtered.append(("FEBRUARY 2021", february2021))
        }

        if march2021.count > 0 {
            filtered.append(("MARCH 2021", march2021))
        }

        if april2021.count > 0 {
            filtered.append(("APRIL 2021", april2021))
        }

        if may2021.count > 0 {
            filtered.append(("MAY 2021", may2021))
        }

        if june2021.count > 0 {
            filtered.append(("JUNE 2021", june2021))
        }

        if july2021.count > 0 {
            filtered.append(("JULY 2021", july2021))
        }

        if august2021.count > 0 {
            filtered.append(("AUGUST 2021", august2021))
        }

        if september2021.count > 0 {
            filtered.append(("SEPTEMBER 2021", september2021))
        }

        if october2021.count > 0 {
            filtered.append(("OCTOBER 2021", october2021))
        }

        if november2021.count > 0 {
            filtered.append(("NOVEMBER 2021", november2021))
        }

        if december2021.count > 0 {
            filtered.append(("DECEMBER 2021", december2021))
        }
        
        if january2022.count > 0 {
            filtered.append(("JANUARY 2022", january2022))
        }
        
        if february2022.count > 0 {
            filtered.append(("FEBRUARY 2022", february2022))
        }
        
        if march2022.count > 0 {
            filtered.append(("MARCH 2022", march2022))
        }

        if april2022.count > 0 {
            filtered.append(("APRIL 2022", april2022))
        }

        if may2022.count > 0 {
            filtered.append(("MAY 2022", may2022))
        }

        if june2022.count > 0 {
            filtered.append(("JUNE 2022", june2022))
        }

        if july2022.count > 0 {
            filtered.append(("JULY 2022", july2022))
        }

        if august2022.count > 0 {
            filtered.append(("AUGUST 2022", august2022))
        }

        if september2022.count > 0 {
            filtered.append(("SEPTEMBER 2022", september2022))
        }

        if october2022.count > 0 {
            filtered.append(("OCTOBER 2022", october2022))
        }

        if november2022.count > 0 {
            filtered.append(("NOVEMBER 2022", november2022))
        }

        if december2022.count > 0 {
            filtered.append(("DECEMBER 2022", december2022))
        }
        
        return filtered
    }
}
