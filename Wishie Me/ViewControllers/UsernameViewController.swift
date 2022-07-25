import UIKit

class UsernameViewController: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var lblMessage: UILabel!
    
    var rightBarButton = UIBarButtonItem()
    var isSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(title: Strings.NEXT, style: .plain, target: self, action: #selector(nextClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if isSuccess {
            if UserData.isSocialLogin != nil {
                if let vc = ViewControllerHelper.getViewController(ofType: .PhotoViewController) as? PhotoViewController {
                    UserData.userName = txtUserName.text
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                if let vc = ViewControllerHelper.getViewController(ofType: .PasswordViewController) as? PasswordViewController {
                    UserData.userName = txtUserName.text
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        if (txtUserName.text?.count ?? 0) >= 3 {
            checkUserNameAvailability()
        }
        else {
            isSuccess = false
            lblMessage.text = ""
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension UsernameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let ACCEPTABLE_CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789_."
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")

        return (string == filtered)
    }
}

// MARK: - API CALL
extension UsernameViewController {
    func checkUserNameAvailability() {
        let params: [String: AnyObject] = [WSRequestParams.username: txtUserName.text as AnyObject]
        WSManager.wsCallUsername(params) { (isSuccess, message) in
            if isSuccess {
                self.rightBarButton.tintColor = WishieMeColors.greenColor
                self.lblMessage.textColor = WishieMeColors.greenColor
            }
            else {
                self.rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
                self.lblMessage.textColor = UIColor.red
            }
            
            self.isSuccess = isSuccess
            self.lblMessage.text = message
        }
    }
}
