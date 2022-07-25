import UIKit

class EditUsernameViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var lblFooter: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    var rightBarButton = UIBarButtonItem()
    var username = ""
    var isEditable = false
    
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        tableView.tableFooterView = footerView
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Username"
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? EditUsernameCell {
            if !(cell.txtUsername.text?.isEmpty ?? true) && (cell.txtUsername.text?.count ?? 0) > 2 {
                if isEditable {
                    editUsername(cell.txtUsername.text ?? "")
                }
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        if (sender.text?.count ?? 0) >= 3 {
            checkUserNameAvailability(sender.text ?? "")
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditUsernameViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditUsernameCell, for: indexPath) as! EditUsernameCell
        
        cell.txtUsername.text = username
        cell.txtUsername.addTarget(self, action: #selector(valueChanged(_:)), for: .editingChanged)
        
        return cell
    }
}

// MARK: - API CALL
extension EditUsernameViewController {
    func checkUserNameAvailability(_ text: String) {
        let params: [String: AnyObject] = [WSRequestParams.username: text as AnyObject]
        WSManager.wsCallUsername(params) { (isSuccess, message) in
            if isSuccess {
                self.rightBarButton.tintColor = WishieMeColors.greenColor
                self.lblUsername.textColor = WishieMeColors.greenColor
                self.lblUsername.text = message
                self.isEditable = true
            }
            else {
                if text == self.username {
                    self.rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
                    self.lblUsername.textColor = UIColor.red
                    self.lblUsername.text = nil
                }
                else {
                    self.rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
                    self.lblUsername.textColor = UIColor.red
                    self.lblUsername.text = message
                }
                
                self.isEditable = false
            }
        }
    }
    
    func editUsername(_ text: String) {
        let params: [String: AnyObject] = [WSRequestParams.username: text as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
