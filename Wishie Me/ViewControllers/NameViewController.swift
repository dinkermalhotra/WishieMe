import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtlastName: UITextField!
    
    var rightBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupName()
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
    
    func setupName() {
        if UserData.firstName != nil && UserData.lastName != nil {
            txtFirstName.text = UserData.firstName ?? ""
            txtlastName.text = UserData.lastName ?? ""
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if !(txtFirstName.text?.isEmpty ?? true) && !(txtlastName.text?.isEmpty ?? true) {
            if let vc = ViewControllerHelper.getViewController(ofType: .BirthdayViewController) as? BirthdayViewController {
                UserData.firstName = txtFirstName.text
                UserData.lastName = txtlastName.text
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        if !(txtFirstName.text?.isEmpty ?? true) && !(txtlastName.text?.isEmpty ?? true) {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
}

// MARK - UITEXTEFIELD DELEGATE
extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName {
            txtlastName.becomeFirstResponder()
        } else {
            txtlastName.resignFirstResponder()
        }
        
        return true
    }
}

