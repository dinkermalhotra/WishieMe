import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    var rightBarButton = UIBarButtonItem()
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupPhoto()
        
        profileImage.layer.cornerRadius = 65
        profileImage.clipsToBounds = true
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(profileImageClicked(_:))))
    }

    func setupPhoto() {
        if let imageUrl = UserData.imageUrl {
            if let data = try? Data.init(contentsOf: imageUrl) {
                self.imageData = data
                profileImage.image = UIImage.init(data: data)
                rightBarButton.tintColor = WishieMeColors.greenColor
                rightBarButton.title = Strings.NEXT
            }
        }
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(title: Strings.SKIP, style: .plain, target: self, action: #selector(skipClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func profileImageClicked(_ gesture: UITapGestureRecognizer) {
        Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func skipClicked(_ sender: UIBarButtonItem) {
        if UserData.isSocialLogin != nil {
            socialRegister()
        }
        else {
            registerUser()
        }
    }
    
    @IBAction func chooseProfilePicture(_ sender: UIButton) {
        Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.TAKE_PHOTO, actionOne: takeNewPhotoFromCamera, titleTwo: Strings.CHOOSE_PHOTO, actionTwo: choosePhotoFromExistingImages, styleOneType: .default, styleTwoType: .default)
    }
}

// MARK: - UIIMAGEPICKERCONTROLLER DELEGAT
extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takeNewPhotoFromCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.camera
        self.present(picker, animated: true, completion: nil)
    }
    
    func choosePhotoFromExistingImages() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        DispatchQueue.main.async {
            self.profileImage.image = editedImage
            self.imageData = editedImage.jpegData(compressionQuality: 0.5)
            
            self.rightBarButton.tintColor = WishieMeColors.greenColor
            self.rightBarButton.title = Strings.NEXT
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - API CALL
extension PhotoViewController {
    func registerUser() {
        let params: [String: AnyObject] = [WSRequestParams.phone: UserData.phoneNumber as AnyObject,
                                           WSRequestParams.firstName: UserData.firstName as AnyObject,
                                           WSRequestParams.lastName: UserData.lastName as AnyObject,
                                           WSRequestParams.dob: UserData.dateOfBirth as AnyObject,
                                           WSRequestParams.gender: UserData.gender as AnyObject,
                                           WSRequestParams.username: UserData.userName as AnyObject,
                                           WSRequestParams.password: UserData.password as AnyObject,
                                           WSRequestParams.profileImage: Helper.convertBase64Image(imageData) as AnyObject]
        WSManager.wsCallRegister(params) { (isSuccess, message) in
            if isSuccess {
                if let vc = ViewControllerHelper.getViewController(ofType: .InviteFriendsViewController) as? InviteFriendsViewController {
                    vc.isFromSignup = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func socialRegister() {
        let params: [String: AnyObject] = [WSRequestParams.email: UserData.email as AnyObject,
                                           WSRequestParams.firstName: UserData.firstName as AnyObject,
                                           WSRequestParams.lastName: UserData.lastName as AnyObject,
                                           WSRequestParams.dob: UserData.dateOfBirth as AnyObject,
                                           WSRequestParams.gender: UserData.gender as AnyObject,
                                           WSRequestParams.username: UserData.userName as AnyObject,
                                           WSRequestParams.profileImage: Helper.convertBase64Image(imageData) as AnyObject,
                                           WSRequestParams.facebookId: UserData.facebookId as AnyObject,
                                           WSRequestParams.gmailId: UserData.gmailId as AnyObject,
                                           WSRequestParams.twitterId: UserData.twitterId as AnyObject]
        WSManager.wsCallSocialAuth(params) { (isSuccess, message) in
            if isSuccess {
                if let vc = ViewControllerHelper.getViewController(ofType: .InviteFriendsViewController) as? InviteFriendsViewController {
                    vc.isFromSignup = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
