struct ViewControllerIdentifiers {
    
    static let AccountNotificationsViewController       = "AccountNotificationsViewController"
    static let AddReminderViewController                = "AddReminderViewController"
    static let BirthdayViewController                   = "BirthdayViewController"
    static let BlockViewController                      = "BlockViewController"
    static let CalendarViewController                   = "CalendarViewController"
    static let CameraViewController                     = "CameraViewController"
    static let CreateBirthdayViewController             = "CreateBirthdayViewController"
    static let DaysViewController                       = "DaysViewController"
    static let EditBioViewController                    = "EditBioViewController"
    static let EditBirthdayViewController               = "EditBirthdayViewController"
    static let EditContactDetailsViewController         = "EditContactDetailsViewController"
    static let EditNameViewController                   = "EditNameViewController"
    static let EditPasswordViewController               = "EditPasswordViewController"
    static let EditProfileViewController                = "EditProfileViewController"
    static let EditUsernameViewController               = "EditUsernameViewController"
    static let FeedsViewController                      = "FeedsViewController"
    static let FriendsViewController                    = "FriendsViewController"
    static let FriendProfileViewController              = "FriendProfileViewController"
    static let FriendRequestViewController              = "FriendRequestViewController"
    static let FullImageViewController                  = "FullImageViewController"
    static let GenderViewController                     = "GenderViewController"
    static let HomeViewController                       = "HomeViewController"
    static let InviteFriendsViewController              = "InviteFriendsViewController"
    static let LabelChangeViewController                = "LabelChangeViewController"
    static let LabelMoveViewController                  = "LabelMoveViewController"
    static let LabelsCreateViewController               = "LabelsCreateViewController"
    static let LabelsViewController                     = "LabelsViewController"
    static let LoginNavigationController                = "LoginNavigationController"
    static let LoginViewController                      = "LoginViewController"
    static let ManageUsersViewController                = "ManageUsersViewController"
    static let NameViewController                       = "NameViewController"
    static let NotesViewController                      = "NotesViewController"
    static let NotificationViewController               = "NotificationViewController"
    static let OtpViewController                        = "OtpViewController"
    static let PasswordViewController                   = "PasswordViewController"
    static let PasswordResetViewController              = "PasswordResetViewController"
    static let PhotoViewController                      = "PhotoViewController"
    static let PrivacyPolicyViewController              = "PrivacyPolicyViewController"
    static let ProfileViewController                    = "ProfileViewController"
    static let PushNotificationsViewController          = "PushNotificationsViewController"
    static let ResetPasswordWithPhoneViewController     = "ResetPasswordWithPhoneViewController"
    static let SavedWishieViewController                = "SavedWishieViewController"
    static let SearchFriendViewController               = "SearchFriendViewController"
    static let SettingsViewController                   = "SettingsViewController"
    static let ShareWithFriendsViewController           = "ShareWithFriendsViewController"
    static let SignupViewController                     = "SignupViewController"
    static let TabbarViewController                     = "TabbarViewController"
    static let TermsAndConditionsViewController         = "TermsAndConditionsViewController"
    static let TonesViewController                      = "TonesViewController"
    static let UsernameViewController                   = "UsernameViewController"
    static let UserProfileViewController                = "UserProfileViewController"
    static let UserProfileNotAvailableController        = "UserProfileNotAvailableController"
    static let VerifyEmailViewController                = "VerifyEmailViewController"
    static let VerifyOtpViewController                  = "VerifyOtpViewController"
    static let VerifyPhoneNumberViewController          = "VerifyPhoneNumberViewController"
    static let VideoViewController                      = "VideoViewController"
    static let VideoShareViewController                 = "VideoShareViewController"
}

import UIKit

enum ViewControllerType {
    case AccountNotificationsViewController
    case AddReminderViewController
    case BirthdayViewController
    case BlockViewController
    case CalendarViewController
    case CameraViewController
    case CreateBirthdayViewController
    case DaysViewController
    case EditBioViewController
    case EditBirthdayViewController
    case EditContactDetailsViewController
    case EditNameViewController
    case EditPasswordViewController
    case EditProfileViewController
    case EditUsernameViewController
    case FeedsViewController
    case FriendsViewController
    case FriendProfileViewController
    case FriendRequestViewController
    case FullImageViewController
    case GenderViewController
    case HomeViewController
    case InviteFriendsViewController
    case LabelChangeViewController
    case LabelMoveViewController
    case LabelsCreateViewController
    case LabelsViewController
    case LoginNavigationController
    case LoginViewController
    case ManageUsersViewController
    case NameViewController
    case NotesViewController
    case NotificationViewController
    case OtpViewController
    case PasswordViewController
    case PasswordResetViewController
    case PhotoViewController
    case PrivacyPolicyViewController
    case ProfileViewController
    case PushNotificationsViewController
    case ResetPasswordWithPhoneViewController
    case SavedWishieViewController
    case SearchFriendViewController
    case SettingsViewController
    case ShareWithFriendsViewController
    case SignupViewController
    case TabbarViewController
    case TermsAndConditionsViewController
    case TonesViewController
    case UsernameViewController
    case UserProfileViewController
    case UserProfileNotAvailableController
    case VerifyEmailViewController
    case VerifyOtpViewController
    case VerifyPhoneNumberViewController
    case VideoViewController
    case VideoShareViewController
}

class ViewControllerHelper: NSObject {
    
    // This is used to retirve view controller and intents to reutilize the common code.
    
    class func getViewController(ofType viewControllerType: ViewControllerType) -> UIViewController {
        var viewController: UIViewController?
        let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        
        // Login Storyboard
        if viewControllerType == .LoginViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LoginViewController) as! LoginViewController
        }
        else if viewControllerType == .SignupViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.SignupViewController) as! SignupViewController
        }
        else if viewControllerType == .OtpViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.OtpViewController) as! OtpViewController
        }
        else if viewControllerType == .NameViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.NameViewController) as! NameViewController
        }
        else if viewControllerType == .BirthdayViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.BirthdayViewController) as! BirthdayViewController
        }
        else if viewControllerType == .GenderViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.GenderViewController) as! GenderViewController
        }
        else if viewControllerType == .UsernameViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.UsernameViewController) as! UsernameViewController
        }
        else if viewControllerType == .PasswordViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.PasswordViewController) as! PasswordViewController
        }
        else if viewControllerType == .PhotoViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.PhotoViewController) as! PhotoViewController
        }
        else if viewControllerType == .InviteFriendsViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.InviteFriendsViewController) as! InviteFriendsViewController
        }
        else if viewControllerType == .ResetPasswordWithPhoneViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ResetPasswordWithPhoneViewController) as! ResetPasswordWithPhoneViewController
        }
        else if viewControllerType == .PasswordResetViewController {
            viewController = loginStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.PasswordResetViewController) as! PasswordResetViewController
        }// Main Storyboard
        else if viewControllerType == .TabbarViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.TabbarViewController) as! TabbarViewController
        }
        else if viewControllerType == .HomeViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.HomeViewController) as! HomeViewController
        }
        else if viewControllerType == .FeedsViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.FeedsViewController) as! FeedsViewController
        }
        else if viewControllerType == .NotificationViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.NotificationViewController) as! NotificationViewController
        }
        else if viewControllerType == .ProfileViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ProfileViewController) as! ProfileViewController
        }
        else if viewControllerType == .CameraViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.CameraViewController) as! CameraViewController
        }
        else if viewControllerType == .UserProfileViewController {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.UserProfileViewController) as! UserProfileViewController
        } // Settings Storyboard
        else if viewControllerType == .SettingsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.SettingsViewController) as! SettingsViewController
        }
        else if viewControllerType == .LabelsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LabelsViewController) as! LabelsViewController
        }
        else if viewControllerType == .LabelsCreateViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LabelsCreateViewController) as! LabelsCreateViewController
        }
        else if viewControllerType == .PushNotificationsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.PushNotificationsViewController) as! PushNotificationsViewController
        }
        else if viewControllerType == .AddReminderViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.AddReminderViewController) as! AddReminderViewController
        }
        else if viewControllerType == .DaysViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.DaysViewController) as! DaysViewController
        }
        else if viewControllerType == .TonesViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.TonesViewController) as! TonesViewController
        }
        else if viewControllerType == .EditProfileViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditProfileViewController) as! EditProfileViewController
        }
        else if viewControllerType == .ManageUsersViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ManageUsersViewController) as! ManageUsersViewController
        }
        else if viewControllerType == .EditUsernameViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditUsernameViewController) as! EditUsernameViewController
        }
        else if viewControllerType == .EditNameViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditNameViewController) as! EditNameViewController
        }
        else if viewControllerType == .EditBirthdayViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditBirthdayViewController) as! EditBirthdayViewController
        }
        else if viewControllerType == .EditBioViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditBioViewController) as! EditBioViewController
        }
        else if viewControllerType == .LabelMoveViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LabelMoveViewController) as! LabelMoveViewController
        }
        else if viewControllerType == .EditContactDetailsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditContactDetailsViewController) as! EditContactDetailsViewController
        }
        else if viewControllerType == .VerifyPhoneNumberViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.VerifyPhoneNumberViewController) as! VerifyPhoneNumberViewController
        }
        else if viewControllerType == .VerifyOtpViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.VerifyOtpViewController) as! VerifyOtpViewController
        }
        else if viewControllerType == .VerifyEmailViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.VerifyEmailViewController) as! VerifyEmailViewController
        }
        else if viewControllerType == .EditPasswordViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.EditPasswordViewController) as! EditPasswordViewController
        }
        else if viewControllerType == .VideoViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.VideoViewController) as! VideoViewController
        }
        else if viewControllerType == .TermsAndConditionsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.TermsAndConditionsViewController) as! TermsAndConditionsViewController
        }
        else if viewControllerType == .PrivacyPolicyViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.PrivacyPolicyViewController) as! PrivacyPolicyViewController
        }
        else if viewControllerType == .SavedWishieViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.SavedWishieViewController) as! SavedWishieViewController
        }
        else if viewControllerType == .BlockViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.BlockViewController) as! BlockViewController
        }
        else if viewControllerType == .AccountNotificationsViewController {
            viewController = settingsStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.AccountNotificationsViewController) as! AccountNotificationsViewController
        }// Dashboard Storyboard
        else if viewControllerType == .CreateBirthdayViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.CreateBirthdayViewController) as! CreateBirthdayViewController
        }
        else if viewControllerType == .NotesViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.NotesViewController) as! NotesViewController
        }
        else if viewControllerType == .UserProfileNotAvailableController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.UserProfileNotAvailableController) as! UserProfileNotAvailableController
        }
        else if viewControllerType == .CalendarViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.CalendarViewController) as! CalendarViewController
        }
        else if viewControllerType == .SearchFriendViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.SearchFriendViewController) as! SearchFriendViewController
        }
        else if viewControllerType == .FriendProfileViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.FriendProfileViewController) as! FriendProfileViewController
        }
        else if viewControllerType == .FriendRequestViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.FriendRequestViewController) as! FriendRequestViewController
        }
        else if viewControllerType == .FriendsViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.FriendsViewController) as! FriendsViewController
        }
        else if viewControllerType == .VideoShareViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.VideoShareViewController) as! VideoShareViewController
        }
        else if viewControllerType == .ShareWithFriendsViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ShareWithFriendsViewController) as! ShareWithFriendsViewController
        }
        else if viewControllerType == .FullImageViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.FullImageViewController) as! FullImageViewController
        }
        else if viewControllerType == .LabelChangeViewController {
            viewController = dashboardStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LabelChangeViewController) as! LabelChangeViewController
        }
        else {
            print("Unknown view controller type")
        }
        
        if let vc = viewController {
            return vc
        } else {
            return UIViewController()
        }
    }
}

