import UIKit

class EditNameViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var rightBarButton = UIBarButtonItem()
    var firstName = ""
    var lastName = ""
    
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Name"
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func checkNameValidity() {
        if !firstName.isEmpty && !lastName.isEmpty {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if !firstName.isEmpty && !lastName.isEmpty && rightBarButton.tintColor != UIColor.officialApplePlaceholderGray {
            self.editName()
        }
    }
    
    @IBAction func valueChangedFirstName(_ sender: UITextField) {
        firstName = sender.text ?? ""
        checkNameValidity()
    }
    
    @IBAction func valueChangedLastName(_ sender: UITextField) {
        lastName = sender.text ?? ""
        checkNameValidity()
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditNameViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditFirstNameCell, for: indexPath) as! EditFirstNameCell
            
            cell.txtFirstName.text = firstName
            cell.txtFirstName.addTarget(self, action: #selector(valueChangedFirstName(_:)), for: .editingChanged)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditLastNameCell, for: indexPath) as! EditLastNameCell
            
            cell.txtLastName.text = lastName
            cell.txtLastName.addTarget(self, action: #selector(valueChangedLastName(_:)), for: .editingChanged)
            
            return cell
        }
    }
}

// MARK: - API CALL
extension EditNameViewController {
    func editName() {
        let params: [String: AnyObject] = [WSRequestParams.firstName: firstName as AnyObject,
                                           WSRequestParams.lastName: lastName as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
