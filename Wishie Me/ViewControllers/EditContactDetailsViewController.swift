import UIKit

class EditContactDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var email = ""
    var mobile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Contact Details"
        
        let rightBarButton = UIBarButtonItem.init(title: Strings.UPDATE, style: .plain, target: self, action: #selector(updateClicked(_:)))
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func emailClicked() {
        if let vc = ViewControllerHelper.getViewController(ofType: .VerifyEmailViewController) as? VerifyEmailViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func phoneNumberClicked() {
        if let vc = ViewControllerHelper.getViewController(ofType: .VerifyPhoneNumberViewController) as? VerifyPhoneNumberViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func parseNumber(_ number: String) -> String {
        let countryCode = PhoneNumberRecognition.parseNumber(number)
        if countryCode != nil {
            let newNumber = number.replacingOccurrences(of: countryCode ?? "", with: "\(countryCode ?? "") ")
            return newNumber
        }
        else {
            return "+\(number)"
        }
    }
    
    @IBAction func updateClicked(_ sender: UIBarButtonItem) {
        Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.EMAIL, actionOne: emailClicked, titleTwo: Strings.PHONE_NUMBER, actionTwo: phoneNumberClicked, styleOneType: .default, styleTwoType: .default)
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditContactDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditContactDetailCell, for: indexPath)
        
        if indexPath.section == 0 {
            if email.isEmpty {
                cell.textLabel?.text = Strings.ADD_EMAIL
                cell.textLabel?.textColor = WishieMeColors.greenColor
                cell.detailTextLabel?.text = nil
            }
            else {
                cell.textLabel?.text = email
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.text = Strings.VERIFIED
            }
            cell.imageView?.image = #imageLiteral(resourceName: "ic_mail")
        }
        else {
            if mobile.isEmpty {
                cell.textLabel?.text = Strings.ADD_PHONE_NUMBER
                cell.textLabel?.textColor = WishieMeColors.greenColor
                cell.detailTextLabel?.text = nil
            }
            else {
                cell.textLabel?.text = self.parseNumber("+\(mobile)")
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.text = Strings.VERIFIED
            }
            cell.imageView?.image = #imageLiteral(resourceName: "ic_phone")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .VerifyEmailViewController) as? VerifyEmailViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if mobile.isEmpty {
                if let vc = ViewControllerHelper.getViewController(ofType: .VerifyPhoneNumberViewController) as? VerifyPhoneNumberViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
