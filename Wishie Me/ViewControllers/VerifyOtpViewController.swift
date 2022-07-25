import UIKit
import FirebaseAuth

class VerifyOtpViewController: UIViewController {

    @IBOutlet weak var txtFirst: WishieMeTextField!
    @IBOutlet weak var txtSecond: WishieMeTextField!
    @IBOutlet weak var txtThird: WishieMeTextField!
    @IBOutlet weak var txtFourth: WishieMeTextField!
    @IBOutlet weak var txtFifth: WishieMeTextField!
    @IBOutlet weak var txtSixth: WishieMeTextField!
    @IBOutlet weak var lblOtpSend: UILabel!
    @IBOutlet weak var btnVerify: WishieMeButton!
    @IBOutlet var btnResend: UIButton!
    
    var email = ""
    var verificationID = ""
    var phoneNumber = ""
    var timer: Timer?
    var counter = 60
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        lblOtpSend.text = "We have sent an OTP to \(email.isEmpty ? phoneNumber : email)"
        txtFirst.becomeFirstResponder()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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
    
    @objc func updateTime() {
        if counter > 0 {
            counter -= 1
            btnResend.setTitle("\(Strings.RESEND_OTP) \(counter) secs", for: UIControl.State())
            btnResend.setTitleColor(WishieMeColors.lightGrayColor, for: UIControl.State())
        }
        else {
            timer?.invalidate()
            counter = 60
            btnResend.setTitle(Strings.RESEND, for: UIControl.State())
            btnResend.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func resendOtp() {        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
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

            self.editPhoneNumber()
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyClicked(_ sender: UIButton) {
        if !(txtFirst.text?.isEmpty ?? true) || !(txtSecond.text?.isEmpty ?? true) || !(txtThird.text?.isEmpty ?? true) || !(txtFourth.text?.isEmpty ?? true) || !(txtFifth.text?.isEmpty ?? true) || !(txtSixth.text?.isEmpty ?? true) {
            if email.isEmpty {
                verifyCredentials()
            }
            else {
                editEmail()
            }
        }
    }
    
    @IBAction func resendClicked(_ sender: UIButton) {
        resendOtp()
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension VerifyOtpViewController: UITextFieldDelegate {
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
                btnVerify.isEnabled = true
                
                if email.isEmpty {
                    verifyCredentials()
                }
                else {
                    editEmail()
                }
            }
            else {
                btnVerify.isEnabled = false
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
                btnVerify.isEnabled = true
                if email.isEmpty {
                    verifyCredentials()
                }
                else {
                    editEmail()
                }
            }
            else {
                btnVerify.isEnabled = false
            }
            
            return false
        }
        else if (textField.text?.count ?? 0) >= 1 {
            textField.text = string
            
            if !(txtFirst.text?.isEmpty ?? true) && !(txtSecond.text?.isEmpty ?? true) && !(txtThird.text?.isEmpty ?? true) && !(txtFourth.text?.isEmpty ?? true) && !(txtFifth.text?.isEmpty ?? true) && !(txtSixth.text?.isEmpty ?? true) {
                btnVerify.isEnabled = true
                if email.isEmpty {
                    verifyCredentials()
                }
                else {
                    editEmail()
                }
            }
            else {
                btnVerify.isEnabled = false
            }
            
            return false
        }
        
        return true
    }
}

// MARK: - API CALL
extension VerifyOtpViewController {
    func editPhoneNumber() {
        let params: [String: AnyObject] = [WSRequestParams.phone: phoneNumber as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            for controller in (self.navigationController?.viewControllers ?? [UIViewController]()) {
                if controller.isKind(of: EditProfileViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
                
                if controller.isKind(of: SettingsViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    func editEmail() {
        let params: [String: AnyObject] = [WSRequestParams.email: email as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            for controller in (self.navigationController?.viewControllers ?? [UIViewController]()) {
                if controller.isKind(of: EditProfileViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
}
