import UIKit
import SDWebImage

protocol ManageUsersDelegate {
    func refreshData(_ birthdays: [Birthdays])
}

var manageUsersDelegate: ManageUsersDelegate?

class ManageUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var birthdays = [Birthdays]()
    var filteredBirthdays = [Birthdays]()
    var labelName = ""
    var labelId: Int = 0
    var selectedTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manageUsersDelegate = self
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = labelName
        self.navigationController?.navigationBar.tintColor = WishieMeColors.greenColor
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_plus"), style: .plain, target: self, action: #selector(newLabelClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func newLabelClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelMoveViewController) as? LabelMoveViewController {
            vc.labelName = labelName
            vc.labelId = labelId
            vc.selectedTag = selectedTag
            vc.birthdaysInLabel = self.filteredBirthdays
            let navigationController = UINavigationController.init(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - CUSTOM DELEGATE
extension ManageUsersViewController: ManageUsersDelegate {
    func refreshData(_ birthdays: [Birthdays]) {
        self.birthdays = birthdays
        self.filteredBirthdays = birthdays
        
        self.tableView.reloadData()
    }
}

// MARK: - UISEARCHBAR DELEGATE
extension ManageUsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.birthdays = filteredBirthdays.filter {
                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }
            
            self.tableView.reloadData()
        }
        else {
            self.birthdays = self.filteredBirthdays
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension ManageUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeCell, for: indexPath) as! HomeCell
        
        let value = birthdays[indexPath.row]
        
        if value.friend != nil {
            cell.imgProfile.layer.borderWidth = 1.0
            cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
        }
        else {
            cell.imgProfile.layer.borderWidth = 0
            cell.imgProfile.layer.borderColor = nil
        }
        
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
        
        cell.lblName.text = "\(value.firstName) \(value.lastName)"
        cell.lblDaysLeft.text = "\(value.daysLeft)"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = birthdays[indexPath.row]

        if value.friend != nil {
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
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}
