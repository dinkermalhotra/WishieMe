import UIKit
import SDWebImage
import StoreKit
import MessageUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userProfile: Profile?
    //var account = ["My Labels", "Push Notifications", "Saved Wishies", "Invite Friends", "Blocked"]
    var account = ["My Labels", "Daily Reminders", "Account Notifications", "Invite Friends", "Blocked"]
    var accountImages = [#imageLiteral(resourceName: "ic_my_labels"), #imageLiteral(resourceName: "ic_daily_reminder"), #imageLiteral(resourceName: "ic_account_notification"), #imageLiteral(resourceName: "ic_invite_friends"), #imageLiteral(resourceName: "ic_block")]
    var helpCentre = ["Feedback", "Report a Problem"]
    var helpCentreImages = [#imageLiteral(resourceName: "ic_feedback"), #imageLiteral(resourceName: "ic_report_a_problem")]
    var otherInformation = ["Privacy Policy", "Terms of Use", "Rate Us"]
    var otherInformationImages = [#imageLiteral(resourceName: "ic_privacy_policy"), #imageLiteral(resourceName: "ic_terms_conditions"), #imageLiteral(resourceName: "ic_rate_us")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Settings"
        NotificationCenter.default.addObserver(self, selector: #selector(updateData(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PROFILE), object: nil)
        
        if !WSManager.isConnectedToInternet() {
            Helper.showToast(onVC: self)
        }
    }
    
    @objc func updateData(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let userProfile = notificationUserInfo[UPDATE_PROFILE] as? Profile {
                self.userProfile = userProfile
                self.tableView.reloadData()
            }
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
    
    func sendFeedbackMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([WebService.feedbackMail])
            mail.setSubject("Feedback for Wishie App (iOS)")
            mail.setMessageBody("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWishie Me Id- \(userProfile?.id ?? 0)", isHTML: false)
            present(mail, animated: true)
        }
    }
    
    func sendProblemMail() {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        let systemInfo = "System Info:\nApp Version: \(currentVersion)\nWishie Me Id- \(userProfile?.id ?? 0)"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([WebService.reportProblemMail])
            mail.setSubject("Bug in Wishie App (iOS)")
            mail.setMessageBody("Description:\n\n\n\n\n\nHow to reproduce (if applicable):\n\n\n\n\n\n\n\n\n\n\n\(systemInfo)", isHTML: false)
            present(mail, animated: true)
        }
    }
    
    @IBAction func phoneNumberClicked(_ sender: UIButton) {
        if let vc = ViewControllerHelper.getViewController(ofType: .VerifyPhoneNumberViewController) as? VerifyPhoneNumberViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW METHODS
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return account.count
        }
        else if section == 2 {
            return helpCentre.count
        }
        else {
            return otherInformation.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.SettingsCell) as! SettingsCell
            
            cell.lblName.text = "\(userProfile?.firstName ?? "") \(userProfile?.lastName ?? "")"
            
            if userProfile?.phone.isEmpty ?? true {
                cell.btnPhoneNumber.setTitle("Add Phone Number", for: .normal)
                cell.btnPhoneNumber.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
                cell.btnPhoneNumber.addTarget(self, action: #selector(phoneNumberClicked(_:)), for: .touchUpInside)
            }
            else {
                cell.btnPhoneNumber.setTitle(self.parseNumber("+\(userProfile?.phone ?? "")"), for: .normal)
                
                if #available(iOS 13.0, *) {
                    cell.btnPhoneNumber.setTitleColor(UIColor.secondaryLabel, for: UIControl.State())
                } else {
                    cell.btnPhoneNumber.setTitleColor(UIColor.lightText, for: UIControl.State())
                }
            }
            
            
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    cell.imgProfile.image = Helper.birthdayImage(self.userProfile?.firstName ?? "")
                    return
                }
            }
            
            let urlStr = userProfile?.profileImage ?? ""
            let urlString:String = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: urlString as String)
            
            cell.imgProfile.sd_setImage(with: url, completed: block)
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.Settings) ?? UITableViewCell()
            
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = account[indexPath.row]
            cell.imageView?.image = accountImages[indexPath.row]
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.Settings) ?? UITableViewCell()
            
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = helpCentre[indexPath.row]
            cell.imageView?.image = helpCentreImages[indexPath.row]
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.Settings) ?? UITableViewCell()
            
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = otherInformation[indexPath.row]
            cell.imageView?.image = otherInformationImages[indexPath.row]
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Strings.PROFILE
        }
        if section == 1 {
            return Strings.ACCOUNT
        }
        else if section == 2 {
            return Strings.HELP_CENTER
        }
        else {
            return Strings.OTHER_INFORMATION
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .EditProfileViewController) as? EditProfileViewController {
                vc.userProfile = userProfile
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let vc = ViewControllerHelper.getViewController(ofType: .LabelsViewController) as? LabelsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.row == 1 {
                if let vc = ViewControllerHelper.getViewController(ofType: .PushNotificationsViewController) as? PushNotificationsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
//            else if indexPath.row == 2 {
//                if let vc = ViewControllerHelper.getViewController(ofType: .SavedWishieViewController) as? SavedWishieViewController {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
            else if indexPath.row == 2 {
                if let vc = ViewControllerHelper.getViewController(ofType: .AccountNotificationsViewController) as? AccountNotificationsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.row == 3 {
                if let vc = ViewControllerHelper.getViewController(ofType: .InviteFriendsViewController) as? InviteFriendsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                if let vc = ViewControllerHelper.getViewController(ofType: .BlockViewController) as? BlockViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else if indexPath.section == 2 {
//            if indexPath.row == 0 {
//
//            }
            if indexPath.row == 0 {
                self.sendFeedbackMail()
            }
            else {
                self.sendProblemMail()
            }
        }
        else {
            if indexPath.row == 0 {
                if let url = URL(string: "https://www.wishie.app/privacy") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
//                if let vc = ViewControllerHelper.getViewController(ofType: .PrivacyPolicyViewController) as? PrivacyPolicyViewController {
//                    let navigationController = UINavigationController.init(rootViewController: vc)
//                    navigationController.modalPresentationStyle = .fullScreen
//                    self.present(navigationController, animated: true, completion: nil)
//                }
            }
            else if indexPath.row == 1 {
                if let url = URL(string: "https://www.wishie.app/terms") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
//                if let vc = ViewControllerHelper.getViewController(ofType: .TermsAndConditionsViewController) as? TermsAndConditionsViewController {
//                    let navigationController = UINavigationController.init(rootViewController: vc)
//                    navigationController.modalPresentationStyle = .fullScreen
//                    self.present(navigationController, animated: true, completion: nil)
//                }
            }
            else {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 90
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.SettingsFooterCellCell) as! SettingsFooterCellCell
            
            return cell
        }
        else {
            return nil
        }
    }
}
