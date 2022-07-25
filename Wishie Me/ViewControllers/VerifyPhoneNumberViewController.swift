import UIKit
import CountryPickerView
import FirebaseAuth

class VerifyPhoneNumberViewController: UIViewController {

    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var btnSendOtp: WishieMeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        countryPicker.dataSource = self
        countryPicker.showCountryCodeInView = false
        countryPicker.countryDetailsLabel.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_14
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNavBar()
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func removeNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func sendOtp() {
        PhoneAuthProvider.provider().verifyPhoneNumber("\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
              // Handles error
                print(error.localizedDescription)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }

            if let vc = ViewControllerHelper.getViewController(ofType: .VerifyOtpViewController) as? VerifyOtpViewController {
                vc.verificationID = verificationID ?? ""
                vc.phoneNumber = "\(self.countryPicker.countryDetailsLabel.text ?? "")\(self.txtPhoneNumber.text ?? "")"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendOtpClicked(_ sender: UIButton) {
        if (txtPhoneNumber.text?.count ?? 0) == 10 {
            Helper.showLoader(onVC: self)
            self.validatePhone("\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")")
        }
        else {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.VALID_PHONE_NUMBER)
        }
    }
}

// MARK: - COUNTRYPICKER DATASOURCE
extension VerifyPhoneNumberViewController: CountryPickerViewDataSource {
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return countryPickerView.tag == countryPicker.tag && true
    }
}

// MARK:- UITEXTFIELD EXTENSION
extension VerifyPhoneNumberViewController: UITextFieldDelegate {
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

// MARK: - API CALL
extension VerifyPhoneNumberViewController {
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
