import UIKit
import Foundation
import Contacts

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
    var image: Data
}

class InviteFriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isFromSignup = false
    var isFromCreateNewBirthday = false
    var contacts = [FetchedContact]()
    var filterData = [FetchedContact]()
    var rightBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isFromSignup {
            setupNavigationBar()
        }
        else if isFromCreateNewBirthday {
            setupNavigationBarNewBirthday()
        }
        else {
            setupNavigationBarGeneral()
        }
        
        fetchContacts()
    }
    
    func setupNavigationBar() {
        self.title = "Invite Friends"
        let leftBarButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.darkGrayColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(title: Strings.SKIP, style: .plain, target: self, action: #selector(skipClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupNavigationBarNewBirthday() {
        self.title = "Add From Contacts"
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func setupNavigationBarGeneral() {
        self.title = "Invite Friends"
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
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
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        let items = [Strings.INVITE_FRIEND_TEXT]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    @IBAction func skipClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
        loginViewControllerDelegate?.sendToHomeView()
    }
    
    @IBAction func inviteClicked(_ sender: UIButton) {
        if isFromCreateNewBirthday {
            let dict = self.contacts[sender.tag]
            createBirthdayViewControllerDelegate?.addFromPhoneBook(dict.firstName, dict.lastName, dict.telephone, dict.image)
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let urlWhats = "whatsapp://send?phone=\(self.contacts[sender.tag].telephone)&text=\(Strings.INVITE_FRIEND_TEXT)"
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
    }
}

// MARK: - UISEARCHBAR DELEGATE
extension InviteFriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.contacts = filterData.filter {
                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }
            
            self.tableView.reloadData()
        }
        else {
            self.contacts = self.filterData
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension InviteFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.InviteFriendCell, for: indexPath) as! InviteFriendCell
        
        cell.lblName.text = "\(contacts[indexPath.row].firstName) \(contacts[indexPath.row].lastName)"
        cell.profileImage.image = UIImage.init(data: contacts[indexPath.row].image)
        
        if isFromCreateNewBirthday {
            cell.btnAdd.setTitle(Strings.ADD, for: UIControl.State())
        }
        
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(inviteClicked(_:)), for: .touchUpInside)
        
        return cell
    }
}
