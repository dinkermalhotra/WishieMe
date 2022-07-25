import UIKit
import AuthenticationServices
import CountryPickerView
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import TwitterKit

class SignupViewController: UIViewController {

    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    var rightBarButton = UIBarButtonItem()
    var isEnable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        countryPicker.dataSource = self
        countryPicker.showCountryCodeInView = false
        countryPicker.countryDetailsLabel.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_14
        lblLogin.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(loginClicked(_:))))
        lblTerms.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(termsClicked(_:))))
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_cross"), style: .plain, target: self, action: #selector(backClicked(_:)))
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
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func loginClicked(_ gesture: UITapGestureRecognizer) {
        let text = lblLogin.text
        let signUpRange = (text! as NSString).range(of: "account? Log in")
        if gesture.didTapAttributedTextInLabel(label: lblLogin, inRange: signUpRange) {
            self.navigationController?.popViewController(animated: true)
        } else {
            print("Wrong Tapped")
        }
    }
    
    @IBAction func termsClicked(_ gesture: UITapGestureRecognizer) {
        let text = lblTerms.text
        let termsRange = (text! as NSString).range(of: "Terms of Use")
        let privacyRange = (text! as NSString).range(of: "Privacy Policy")
        if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: termsRange) {
            if let url = URL.init(string: WebService.termsAndConditions) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: privacyRange) {
            if let url = URL.init(string: WebService.privacyPolicy) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            print("Wrong Tapped")
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        if (sender.text?.count ?? 0) == 10 {
            isEnable = true
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        else {
            isEnable = false
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if isEnable {
            Helper.showLoader(onVC: self)
            self.validatePhone("\(self.countryPicker.countryDetailsLabel.text ?? "")\(self.txtPhoneNumber.text ?? "")")
        }
        else {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.VALID_PHONE_NUMBER)
        }
    }
    
    @IBAction func gmailClicked(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookClicked(_ sender: UIButton) {
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
    
    @IBAction func twitterClicked(_ sender: UIButton) {
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
                
                Helper.showLoader(onVC: self)
                self.socialLogin()
            }
        }
    }
    
    @IBAction func appleClicked(_ sender: UIButton) {
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
    
    func sendOtp() {
        PhoneAuthProvider.provider().verifyPhoneNumber("\(countryPicker.countryDetailsLabel.text ?? "")\(txtPhoneNumber.text ?? "")", uiDelegate: nil) { (verificationID, error) in
            Helper.hideLoader(onVC: self)
            
            if let error = error {
              // Handles error
                print(error.localizedDescription)
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: error.localizedDescription)
                return
            }
            
            if let vc = ViewControllerHelper.getViewController(ofType: .OtpViewController) as? OtpViewController {
                vc.verificationID = verificationID ?? ""
                UserData.phoneNumber = "\(self.countryPicker.countryDetailsLabel.text ?? "")\(self.txtPhoneNumber.text ?? "")"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
                        
                        Helper.showLoader(onVC: self)
                        self.socialLogin()
                    }
                }
            })
        }
    }
}

// MARK: - COUNTRYPICKER DATASOURCE
extension SignupViewController: CountryPickerViewDataSource {
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return countryPickerView.tag == countryPicker.tag && true
    }
}

// MARK: - GOOGLE SIGNIN DELEGATE
extension SignupViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        Helper.showLoader(onVC: self)
        
        if let error = error {
            Helper.hideLoader(onVC: self)
            print(error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                Helper.hideLoader(onVC: self)
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

// MARK: - ASAuthorizationControllerDelegate
extension SignupViewController: ASAuthorizationControllerDelegate {
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
            
            Helper.showLoader(onVC: self)
            self.socialLogin()
        }
    }
}

// MARK:- UITEXTFIELD EXTENSION
extension SignupViewController: UITextFieldDelegate {
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
extension SignupViewController {
    func validatePhone(_ phone: String) {
        let params: [String: AnyObject] = [WSRequestParams.phone: phone as AnyObject]
        WSManager.wsCallValidatePhone(params) { isSuccess, message in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                self.sendOtp()
            }
            else {
                self.isEnable = false
                self.rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
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
            Helper.hideLoader(onVC: self)
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
