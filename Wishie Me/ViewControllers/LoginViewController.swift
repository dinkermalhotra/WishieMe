import UIKit
import AuthenticationServices
import CountryPickerView
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import TwitterKit

protocol LoginViewControllerDelegate {
    func sendToHomeView()
}

var loginViewControllerDelegate: LoginViewControllerDelegate?

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: WishieMeTextField!
    @IBOutlet weak var txtPassword: WishieMeTextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var lblSignUp: UILabel!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var btnLogin: WishieMeButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var phoneView: WishieMeView!
    
    var _settings: SettingsManager?
    
    var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginViewControllerDelegate = self
        countryPicker.dataSource = self
        countryPicker.showCountryCodeInView = false
        countryPicker.countryDetailsLabel.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_14
        btnLogin.layer.borderColor = UIColor.officialApplePlaceholderGray.cgColor
        btnLogin.layer.backgroundColor = UIColor.officialApplePlaceholderGray.cgColor
        lblSignUp.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(signupClicked(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if settings?.accessToken != nil && settings?.accessToken != "" {
            if let vc = ViewControllerHelper.getViewController(ofType: .TabbarViewController) as? TabbarViewController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func withPhoneNumber() {
        if let vc = ViewControllerHelper.getViewController(ofType: .ResetPasswordWithPhoneViewController) as? ResetPasswordWithPhoneViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func withEmail() {
        
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            phoneView.isHidden = true
            txtEmail.isHidden = false
            
            if txtPhoneNumber.isFirstResponder {
                txtEmail.becomeFirstResponder()
            }
        }
        else {
            phoneView.isHidden = false
            txtEmail.isHidden = true
            
            if txtEmail.isFirstResponder {
                txtPhoneNumber.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func showPassword(_ sender: UIButton) {
        if sender.isSelected {
            txtPassword.isSecureTextEntry = true
            sender.isSelected = false
        }
        else {
            txtPassword.isSecureTextEntry = false
            sender.isSelected = true
        }
    }
    
    @IBAction func signupClicked(_ gesture: UITapGestureRecognizer) {
        let text = lblSignUp.text
        let signUpRange = (text! as NSString).range(of: "account? Sign up")
        if gesture.didTapAttributedTextInLabel(label: lblSignUp, inRange: signUpRange) {
            if let signUp = ViewControllerHelper.getViewController(ofType: .SignupViewController) as? SignupViewController {
                self.navigationController?.pushViewController(signUp, animated: true)
            }
        } else {
            print("Wrong Tapped")
        }
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            if txtEmail.text?.isEmpty ?? true || txtPassword.text?.isEmpty ?? true {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ALL_FIELDS_MANDATORY)
            }
            else {
                userLogin()
            }
        }
        else {
            if txtPhoneNumber.text?.isEmpty ?? true || txtPassword.text?.isEmpty ?? true {
                Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ALL_FIELDS_MANDATORY)
            }
            else {
                userLogin()
            }
        }
    }
    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        Helper.showActionAlert(onVC: self, title: Strings.RESET_PASSWORD, titleOne: Strings.PHONE_NUMBER, actionOne: withPhoneNumber, titleTwo: Strings.EMAIL, actionTwo: withEmail, styleOneType: .default, styleTwoType: .default)
    }
    
    @IBAction func btnGmailClicked(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnFacebookClicked(_ sender: UIButton) {
        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email", "public_profile"], from: self, handler: {(result, error) -> Void in
            print(error?.localizedDescription ?? "No error")
            if (error == nil) {
                let fbloginresult: LoginManagerLoginResult = result!
                if (result?.isCancelled)! {
                    return
                }
                
                if(fbloginresult.grantedPermissions.contains("email")) {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func btnTwitterClicked(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn(with: self) { (session, error) in
            if let error = error {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }
            
            if session != nil {
                self.dismiss(animated: true) {
                    print("Logged in ")
                }
                
                let client = TWTRAPIClient.withCurrentUser()
                client.requestEmail { (email, error) in
                    if email != nil {
                        UserData.email = email ?? ""
                    }
                }
                
                client.loadUser(withID: session?.userID ?? "") { (user, error) in
                    guard let twitterUser = user, error == nil else {
                        print("Twitter : TwTRUser is nil, or error has occured: ")
                        print("Twitter error: \(error!.localizedDescription)")
                        return
                    }
                    
                    let userName = twitterUser.name.components(separatedBy: " ")
                    UserData.firstName = userName[0]
                    if userName.count >= 2 {
                        UserData.lastName = userName[1]
                    }
                    
                    UserData.imageUrl = URL.init(string: twitterUser.profileImageLargeURL)
                    UserData.twitterId = twitterUser.userID
                }
                
                self.socialLogin()
            }
        }
    }
    
    @IBAction func btnAppleClicked(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
//        if txtEmail.text?.isEmpty ?? true || txtPassword.text?.isEmpty ?? true {
//            btnLogin.layer.borderColor = UIColor.officialApplePlaceholderGray.cgColor
//            btnLogin.layer.backgroundColor = UIColor.officialApplePlaceholderGray.cgColor
//        }
//        else {
//            btnLogin.layer.borderColor = WishieMeColors.greenColor.cgColor
//            btnLogin.layer.backgroundColor = WishieMeColors.greenColor.cgColor
//        }
    }
    
    // MARK: - LOGIN METHODS
    func getFBUserData() {
        if((AccessToken.current) != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, gender, email, name, picture.width(400).height(400)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil) {
                    print(result ?? [:])
                    
                    if let result = result as? [String: AnyObject] {
                        if let name = result["name"] as? String {
                            let completeName = name.split(separator: " ")
                            UserData.firstName = String(completeName[0])
                            UserData.lastName = (completeName.count > 1 ? String(completeName[1]) : nil) ?? ""
                        }
                        
                        if let _fbId = result["id"] as? String {
                            UserData.facebookId = _fbId
                        }
                        
                        if let _email = result["email"] as? String {
                            UserData.email = _email
                        }
                        
                        if let _picture = result["picture"] as? [String: AnyObject] {
                            if let _data = _picture["data"] as? [String: AnyObject] {
                                if let _url = _data["url"] as? String {
                                    UserData.imageUrl = URL.init(string: _url)
                                }
                            }
                        }
                        
                        self.socialLogin()
                    }
                }
            })
        }
    }
}

// MARK: - CUSTOM DELEGATE
extension LoginViewController: LoginViewControllerDelegate {
    func sendToHomeView() {
        DispatchQueue.main.async {
            if let vc = ViewControllerHelper.getViewController(ofType: .TabbarViewController) as? TabbarViewController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - COUNTRYPICKER DATASOURCE
extension LoginViewController: CountryPickerViewDataSource {
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return countryPickerView.tag == countryPicker.tag && true
    }
}

// MARK: - GOOGLE SIGNIN DELEGATE
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }
            
            let userName = authResult?.user.displayName?.components(separatedBy: " ")
            UserData.firstName = userName?[0]
            if (userName?.count ?? 0) >= 2 {
                UserData.lastName = userName?[1]
            }
            
            UserData.gmailId = authResult?.user.uid
            UserData.imageUrl = authResult?.user.photoURL
            UserData.email = authResult?.user.email
            UserData.phoneNumber = authResult?.user.phoneNumber
            
            self.socialLogin()
        }
    }
}
// MARK - UITEXTEFIELD DELEGATE
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtPassword.becomeFirstResponder()
        } else {
            txtPassword.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            UserData.appleId = userIdentifier
            UserData.firstName = fullName?.givenName
            UserData.lastName = fullName?.familyName
            UserData.email = email
            
            self.socialLogin()
        }
    }
}

// MARK: - API CALL
extension LoginViewController {
    func userLogin() {
        var details = ""
        if segmentControl.selectedSegmentIndex == 0 {
            details = txtEmail.text ?? ""
        }
        else {
            details = "\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")"
        }
        
        let params: [String: AnyObject] = [WSRequestParams.username: details as AnyObject,
                                           WSRequestParams.password: txtPassword.text as AnyObject]
        WSManager.wsCallLogin(params) { (isSuccess, message) in
            if isSuccess {
                self.txtEmail.text = ""
                self.txtPhoneNumber.text = ""
                self.txtPassword.text = ""
                
                if let vc = ViewControllerHelper.getViewController(ofType: .TabbarViewController) as? TabbarViewController {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.OOPS, message: message)
            }
        }
    }
    
    func socialLogin() {
        let params: [String: AnyObject] = [WSRequestParams.email: UserData.email as AnyObject,
                                           WSRequestParams.facebookId: UserData.facebookId as AnyObject,
                                           WSRequestParams.gmailId: UserData.gmailId as AnyObject,
                                           WSRequestParams.twitterId: UserData.twitterId as AnyObject,
                                           WSRequestParams.appleId: UserData.appleId as AnyObject]
        WSManager.wsCallSocialLogin(params) { (isSuccess, message) in
            if isSuccess {
                if let vc = ViewControllerHelper.getViewController(ofType: .TabbarViewController) as? TabbarViewController {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
            else {
                if let vc = ViewControllerHelper.getViewController(ofType: .NameViewController) as? NameViewController {
                    UserData.isSocialLogin = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
