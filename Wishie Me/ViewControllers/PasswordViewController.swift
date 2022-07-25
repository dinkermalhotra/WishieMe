import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblEightCharacters: UILabel!
    @IBOutlet weak var lblUppercase: UILabel!
    @IBOutlet weak var lblLowercase: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblSpecialCharacter: UILabel!
    
    var rightBarButton = UIBarButtonItem()
    
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
        if Validator.validatePassword(txtPassword.text ?? "") {
            if let vc = ViewControllerHelper.getViewController(ofType: .PhotoViewController) as? PhotoViewController {
                UserData.password = txtPassword.text
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func showHidePassword(_ sender: UIButton) {
        if sender.isSelected {
            txtPassword.isSecureTextEntry = true
            sender.isSelected = false
        }
        else {
            txtPassword.isSecureTextEntry = false
            sender.isSelected = true
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {        
        lblEightCharacters.textColor = ((sender.text?.count ?? 0) >= 8) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
        lblLowercase.textColor = Validator.validateLowercase(sender.text ?? "")
        lblNumber.textColor = Validator.validateNumber(sender.text ?? "")
        lblSpecialCharacter.textColor = Validator.validateSpecialCharacter(sender.text ?? "")
        lblUppercase.textColor = Validator.validateUppercase(sender.text ?? "")
        rightBarButton.tintColor = Validator.validatePassword(sender.text ?? "") == true ? WishieMeColors.greenColor : UIColor.officialApplePlaceholderGray
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
