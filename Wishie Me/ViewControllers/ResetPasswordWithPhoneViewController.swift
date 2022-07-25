import UIKit
import CountryPickerView
import FirebaseAuth

class ResetPasswordWithPhoneViewController: UIViewController {

    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        countryPicker.showCountryCodeInView = false
        countryPicker.countryDetailsLabel.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_14
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_cross"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendCodeClicked(_ sender: UIButton) {
        if txtPhoneNumber.text?.count == 10 {
            Helper.showLoader(onVC: self)
            self.validatePhone("\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")")
        }
        else {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.VALID_PHONE_NUMBER)
        }
    }
    
    func sendOtp() {
        PhoneAuthProvider.provider().verifyPhoneNumber("\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
              // Handles error
                print(error.localizedDescription)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }

            if let vc = ViewControllerHelper.getViewController(ofType: .OtpViewController) as? OtpViewController {
                vc.isFromPasswordReset = true
                vc.verificationID = verificationID ?? ""
                vc.phoneNumber = "\(self.countryPicker.countryDetailsLabel.text ?? "")\(self.txtPhoneNumber.text ?? "")"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
// MARK:- UITEXTFIELD EXTENSION
extension ResetPasswordWithPhoneViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: API
extension ResetPasswordWithPhoneViewController {
    func validatePhone(_ phone: String) {
        let params: [String: AnyObject] = [WSRequestParams.phone: phone as AnyObject]
        WSManager.wsCallValidatePhone(params) { isSuccess, message in
            Helper.hideLoader(onVC: self)
            if !isSuccess {
                self.sendOtp()
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.OOPS, message: AlertMessages.PHONE_NUMBER_NOT_REGISTERED)
            }
        }
    }
}
