import UIKit
import Firebase

class OtpViewController: UIViewController {

    @IBOutlet weak var txtFirst: WishieMeTextField!
    @IBOutlet weak var txtSecond: WishieMeTextField!
    @IBOutlet weak var txtThird: WishieMeTextField!
    @IBOutlet weak var txtFourth: WishieMeTextField!
    @IBOutlet weak var txtFifth: WishieMeTextField!
    @IBOutlet weak var txtSixth: WishieMeTextField!
    @IBOutlet weak var lblOtpSend: UILabel!
    @IBOutlet weak var btnOtp: UIButton!
    
    var rightBarButton = UIBarButtonItem()
    var verificationID = ""
    var phoneNumber = ""
    var isFromPasswordReset = false
    var timer: Timer?
    var counter = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLabel()
        txtFirst.becomeFirstResponder()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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
    
    func setupLabel() {
        if isFromPasswordReset {
            lblOtpSend.text = "We have sent an OTP to \(phoneNumber)"
        }
        else {
            lblOtpSend.text = "We have sent an OTP to \(UserData.phoneNumber ?? "")"
        }
    }
    
    @objc func updateTime() {
        if counter > 0 {
            counter -= 1
            btnOtp.setTitle("\(Strings.RESEND_OTP) \(counter) secs", for: UIControl.State())
            btnOtp.setTitleColor(WishieMeColors.lightGrayColor, for: UIControl.State())
        }
        else {
            timer?.invalidate()
            counter = 60
            btnOtp.setTitle(Strings.RESEND, for: UIControl.State())
            btnOtp.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func resendOtp() {
        var number = ""
        if phoneNumber.isEmpty || phoneNumber == "" {
            number = UserData.phoneNumber ?? ""
        }
        else {
            number = phoneNumber
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
              // Handles error
                print(error.localizedDescription)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }
            else {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            }
        }
    }
    
    func verifyCredentials() {
        let verificationCode = "\(txtFirst.text ?? "")\(txtSecond.text ?? "")\(txtThird.text ?? "")\(txtFourth.text ?? "")\(txtFifth.text ?? "")\(txtSixth.text ?? "")"
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }
            else {
                if self.timer != nil {
                    self.timer?.invalidate()
                }
                
                if self.isFromPasswordReset {
                    if let vc = ViewControllerHelper.getViewController(ofType: .PasswordResetViewController) as? PasswordResetViewController {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else {
                    if let vc = ViewControllerHelper.getViewController(ofType: .NameViewController) as? NameViewController {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if !(txtFirst.text?.isEmpty ?? true) && !(txtSecond.text?.isEmpty ?? true) && !(txtThird.text?.isEmpty ?? true) && !(txtFourth.text?.isEmpty ?? true) && !(txtFifth.text?.isEmpty ?? true) && !(txtSixth.text?.isEmpty ?? true) {
            verifyCredentials()
        }
    }
    
    @IBAction func resendOtp(_ sender: UIButton) {
        resendOtp()
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension OtpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count ?? 0) < 1 && string.count > 0 {
            if textField == txtFirst {
                txtSecond.becomeFirstResponder()
            }
            if textField == txtSecond {
                txtThird.becomeFirstResponder()
            }
            if textField == txtThird {
                txtFourth.becomeFirstResponder()
            }
            if textField == txtFourth {
                txtFifth.becomeFirstResponder()
            }
            if textField == txtFifth {
                txtSixth.becomeFirstResponder()
            }
            if textField == txtSixth {
                txtSixth.resignFirstResponder()
            }
            
            textField.text = string
            
            if !(txtFirst.text?.isEmpty ?? true) && !(txtSecond.text?.isEmpty ?? true) && !(txtThird.text?.isEmpty ?? true) && !(txtFourth.text?.isEmpty ?? true) && !(txtFifth.text?.isEmpty ?? true) && !(txtSixth.text?.isEmpty ?? true) {
                rightBarButton.tintColor = WishieMeColors.greenColor
                verifyCredentials()
            }
            else {
                rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
            }
            
            return false
        }
        else if (textField.text?.count ?? 0) >= 1 && string.count == 0 {
            if textField == txtSecond {
                txtFirst.becomeFirstResponder()
            }
            if textField == txtThird {
                txtSecond.becomeFirstResponder()
            }
            if textField == txtFourth {
                txtThird.becomeFirstResponder()
            }
            if textField == txtFifth {
                txtFourth.becomeFirstResponder()
            }
            if textField == txtSixth {
                txtFifth.becomeFirstResponder()
            }
            if textField == txtFirst {
                txtFirst.resignFirstResponder()
            }
            
            textField.text = ""
            
            if !(txtFirst.text?.isEmpty ?? true) && !(txtSecond.text?.isEmpty ?? true) && !(txtThird.text?.isEmpty ?? true) && !(txtFourth.text?.isEmpty ?? true) && !(txtFifth.text?.isEmpty ?? true) && !(txtSixth.text?.isEmpty ?? true) {
                rightBarButton.tintColor = WishieMeColors.greenColor
                verifyCredentials()
            }
            else {
                rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
            }
            
            return false
        }
        else if (textField.text?.count ?? 0) >= 1 {
            textField.text = string
            
            if !(txtFirst.text?.isEmpty ?? true) && !(txtSecond.text?.isEmpty ?? true) && !(txtThird.text?.isEmpty ?? true) && !(txtFourth.text?.isEmpty ?? true) && !(txtFifth.text?.isEmpty ?? true) && !(txtSixth.text?.isEmpty ?? true) {
                rightBarButton.tintColor = WishieMeColors.greenColor
                verifyCredentials()
            }
            else {
                rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
            }
            
            return false
        }
        
        return true
    }
}
