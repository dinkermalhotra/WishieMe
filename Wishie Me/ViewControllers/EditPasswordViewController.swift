import UIKit

class EditPasswordViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var lblEightCharacters: UILabel!
    @IBOutlet weak var lblUppercase: UILabel!
    @IBOutlet weak var lblLowercase: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblSpecialCharacter: UILabel!
    
    var password = ""
    var confirmPassword = ""
    var rightBarButton = UIBarButtonItem()
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Password"
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    // MARK: - UIBUTTON ACTIONS
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if password == confirmPassword {
            if Validator.validatePassword(password) && Validator.validatePassword(confirmPassword) {
                editPassword()
            }
        }
    }
    
    @IBAction func showPassword(_ sender: UIButton) {
        let indexPath = IndexPath.init(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? EditPasswordCell {
            if cell.btnShowPassword.isSelected {
                cell.txtPassword.isSecureTextEntry = true
                cell.btnShowPassword.isSelected = false
            }
            else {
                cell.txtPassword.isSecureTextEntry = false
                cell.btnShowPassword.isSelected = true
            }
        }
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        lblEightCharacters.textColor = ((sender.text?.count ?? 0) >= 8) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
        lblLowercase.textColor = Validator.validateLowercase(sender.text ?? "")
        lblNumber.textColor = Validator.validateNumber(sender.text ?? "")
        lblSpecialCharacter.textColor = Validator.validateSpecialCharacter(sender.text ?? "")
        lblUppercase.textColor = Validator.validateUppercase(sender.text ?? "")
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditPasswordViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditPasswordCell, for: indexPath) as! EditPasswordCell
        
        if indexPath.row == 0 {
            cell.btnShowPassword.isHidden = false
            cell.txtPassword.placeholder = "Enter new password"
            cell.txtPassword.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        }
        else {
            cell.btnShowPassword.isHidden = true
            cell.txtPassword.placeholder = "Re-enter new password"
        }
        
        cell.delegate = self
        cell.txtPassword.tag = indexPath.row
        cell.btnShowPassword.tag = indexPath.row
        cell.btnShowPassword.addTarget(self, action: #selector(showPassword(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - TEXTFIELDCELL DELEGATE
extension EditPasswordViewController: TextFieldCellDelegate {
    func shouldChangeEditTextCellText(_ cell: EditPasswordCell?, _ tag: Int, newText: String?) -> Bool {
        if tag == 0 {
            password = newText ?? ""
        }
        else {
            confirmPassword = newText ?? ""
        }
        
        if password == confirmPassword {
            if Validator.validatePassword(password) {
                if Validator.validatePassword(confirmPassword) {
                    rightBarButton.tintColor = WishieMeColors.greenColor
                }
                else {
                    rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
                }
            }
            else {
                rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
            }
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
        
        return true
    }
}

// MARK: - API CALL
extension EditPasswordViewController {
    func editPassword() {
        let params: [String: AnyObject] = [WSRequestParams.password: password as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
