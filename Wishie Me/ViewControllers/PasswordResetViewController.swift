import UIKit

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnReset: WishieMeButton!
    @IBOutlet weak var lblEightCharacters: UILabel!
    @IBOutlet weak var lblUppercase: UILabel!
    @IBOutlet weak var lblLowercase: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblSpecialCharacter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnReset.layer.borderColor = UIColor.officialApplePlaceholderGray.cgColor
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        lblEightCharacters.textColor = ((sender.text?.count ?? 0) >= 8) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
        lblLowercase.textColor = Validator.validateLowercase(sender.text ?? "")
        lblNumber.textColor = Validator.validateNumber(sender.text ?? "")
        lblSpecialCharacter.textColor = Validator.validateSpecialCharacter(sender.text ?? "")
        lblUppercase.textColor = Validator.validateUppercase(sender.text ?? "")
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
    
    @IBAction func ResetClicked(_ sender: UIButton) {
//        Helper.showOKAlertWithCompletion(onVC: self, title: Alert.SUCCESS, message: "Password updated successfully", btnOkTitle: "Ok", onOk: {
//            _ = self.navigationController?.popToRootViewController(animated: true)
//        })
    }
}
