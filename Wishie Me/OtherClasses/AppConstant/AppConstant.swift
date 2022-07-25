import UIKit
import Foundation

// App constants
struct CurrentDevice {
    static let isiPhone     = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    static let iPhone4S     = isiPhone && UIScreen.main.bounds.size.height == 480
    static let isiPhone5    = isiPhone && UIScreen.main.bounds.size.height == 568.0
    static let iPhone6      = isiPhone && UIScreen.main.bounds.size.height == 667.0
    static let iPhone6P     = isiPhone && UIScreen.main.bounds.size.height == 736.0
    static let iPhoneX      = isiPhone && UIScreen.main.bounds.size.height == 812.0
    static let iPhone12     = isiPhone && UIScreen.main.bounds.size.height == 844.0
    static let iPhoneXS_MAX = isiPhone && UIScreen.main.bounds.size.height == 896.0
    
    static let isiPad       = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    static let iPadMini     = isiPad && UIScreen.main.bounds.size.height <= 1024
}

struct AppConstants {
    static let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    static let PORTRAIT_SCREEN_WIDTH  = UIScreen.main.bounds.size.width
    static let PORTRAIT_SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let CURRENT_IOS_VERSION = UIDevice.current.systemVersion
}

struct WishieMeColors {
    static let darkGrayColor = UIColor.init(red: 119/255, green: 119/255, blue: 119/255, alpha: 1.0)
    static let greenColor = UIColor.init(red: 35/255, green: 169/255, blue: 181/255, alpha: 1.0)
    static let lightGrayColor = UIColor.init(hex: "DADADA")
}

struct WishieMeFonts {
    static let FONT_FRIEND_FAMILY_REGULAR_18 = UIFont.init(name: "FAMILY&friend", size: 18)
    static let FONT_MONTSERRAT_MEDIUM_12 = UIFont.init(name: "Montserrat-Medium", size: 12)
    static let FONT_MONTSERRAT_MEDIUM_14 = UIFont.init(name: "Montserrat-Medium", size: 14)
    static let FONT_MONTSERRAT_MEDIUM_16 = UIFont.init(name: "Montserrat-Medium", size: 16)
    static let FONT_MONTSERRAT_MEDIUM_102 = UIFont.init(name: "Montserrat-Medium", size: 102)
    static let FONT_MONTSERRAT_REGULAR_14 = UIFont.init(name: "Montserrat-Regular", size: 14)
    static let FONT_MONTSERRAT_REGULAR_16 = UIFont.init(name: "Montserrat-Regular", size: 16)
    static let FONT_MONTSERRAT_REGULAR_18 = UIFont.init(name: "Montserrat-Regular", size: 18)
    static let FONT_MONTSERRAT_SEMIBOLD_12 = UIFont.init(name: "Montserrat-SemiBold", size: 12)
    static let FONT_MONTSERRAT_SEMIBOLD_14 = UIFont.init(name: "Montserrat-SemiBold", size: 14)
    static let FONT_MONTSERRAT_SEMIBOLD_16 = UIFont.init(name: "Montserrat-SemiBold", size: 16)
    static let FONT_MONTSERRAT_SEMIBOLD_18 = UIFont.init(name: "Montserrat-SemiBold", size: 18)
}

struct CellIds {
    static let AddReminderCell              = "AddReminderCell"
    static let CalendarCell                 = "CalendarCell"
    static let CancelFriendRequestCell      = "CancelFriendRequestCell"
    static let ChooseLabelCell              = "ChooseLabelCell"
    static let CustomRemindersCell          = "CustomRemindersCell"
    static let DatePickerCell               = "DatePickerCell"
    static let DaysCell                     = "DaysCell"
    static let EditBirthdayCell             = "EditBirthdayCell"
    static let EditContactDetailCell        = "EditContactDetailCell"
    static let EditContactDetailsFooterCell = "EditContactDetailsFooterCell"
    static let EditFirstNameCell            = "EditFirstNameCell"
    static let EditLastNameCell             = "EditLastNameCell"
    static let EditPasswordCell             = "EditPasswordCell"
    static let EditProfileCell              = "EditProfileCell"
    static let EditUsernameCell             = "EditUsernameCell"
    static let EffectsCell                  = "EffectsCell"
    static let EmptyCell                    = "EmptyCell"
    static let FeedsCell                    = "FeedsCell"
    static let FriendsCell                  = "FriendsCell"
    static let FriendRequestCell            = "FriendRequestCell"
    static let HomeCell                     = "HomeCell"
    static let HomeFilterCollectionCell     = "HomeFilterCollectionCell"
    static let HomeHeaderCell               = "HomeHeaderCell"
    static let HomeRecentCell               = "HomeRecentCell"
    static let HomeRecentCollectionCell     = "HomeRecentCollectionCell"
    static let InviteFriendCell             = "InviteFriendCell"
    static let LabelMoveCell                = "LabelMoveCell"
    static let LabelsCell                   = "LabelsCell"
    static let LabelsCreateCell             = "LabelsCreateCell"
    static let NotificationBirthdayCell     = "NotificationBirthdayCell"
    static let NoPendingRequests            = "NoPendingRequests"
    static let PushNotificationCell         = "PushNotificationCell"
    static let ReminderCell                 = "ReminderCell"
    static let RemoveReminderCell           = "RemoveReminderCell"
    static let SavedWishieCell              = "SavedWishieCell"
    static let SearchCell                   = "SearchCell"
    static let SearchFriendCell             = "SearchFriendCell"
    static let Settings                     = "Settings"
    static let SettingsCell                 = "SettingsCell"
    static let SettingsFooterCellCell       = "SettingsFooterCellCell"
    static let TonesCell                    = "TonesCell"
    static let TextViewCell                 = "TextViewCell"
}

struct Strings {
    static let ACCOUNT = "ACCOUNT"
    static let ACCEPT_REQUEST = "Accept"
    static let ADD = "Add"
    static let ADD_EMAIL = "Add Email"
    static let ADD_PHONE_NUMBER = "Add Phone Number"
    static let ADD_BIO = "ADD"
    static let ADD_FRIEND = "Add Friend"
    static let ADD_NEW_BIRTHDAY = "Add new birthday"
    static let ADD_REMINDER = "Add Reminder"
    static let BIRTHDAY = "Birthday"
    static let BIRTHDAY_TODAY = "Birthday Today"
    static let BIRTHDAY_TOMORROW = "Birthday Tomorrow"
    static let BLOCK = "Block"
    static let CANCEL = "Cancel"
    static let CANCEL_REQUEST = "Cancel Request"
    static let CHANGE_PHOTO = "Change Photo"
    static let CHANGE_LABEL = "Change Label"
    static let CHOOSE_PHOTO = "Choose Photo"
    static let CLEAR = "Clear"
    static let CONTENT_SIZE = "contentSize"
    static let CREATE_NEW_LABEL = "Create new label"
    static let CUSTOM_REMINDERS = "Custom Reminders"
    static let DATE = "Date"
    static let DAY = "day"
    static let DAYS = "days"
    static let DECLINE_REQUEST = "Decline"
    static let DELETE = "Delete"
    static let DONE = "Done"
    static let EDIT = "Edit"
    static let EDIT_BIO = "EDIT"
    static let EDIT_REMINDER = "Edit Reminder"
    static let EMAIL = "Email"
    static let EVENTS = "EVENTS"
    static let FAKE_PROFILE = "Fake profile/spam"
    static let FAMILY = "Family"
    static let FEMALE = "Female"
    static let FRIENDS = "Friends"
    static let HAPPY_BIRTHDAY = "Happy Birthday!"
    static let HAPPY_BIRTHDAY_WISH = "Wishing you a very Happy Birthday"
    static let HELLO = "Hello"
    static let HELP_CENTER = "HELP CENTER"
    static let INAPPROPRIATE_CONTENT = "Inappropriate content"
    static let INVITE_FRIENDS = "Invite friends"
    static let LABEL = "Label"
    static let LATER_THIS_WEEK = "LATER THIS WEEK"
    static let LATER_THIS_MONTH = "LATER THIS MONTH"
    static let LOGOUT = "Logout"
    static let MALE = "Male"
    static let MANAGE = "Manage"
    static let NAME = "Name"
    static let NEW = "New"
    static let NEXT = "NEXT"
    static let NEXT_WEEK = "NEXT WEEK"
    static let next_week = "next_week"
    static let NO = "No"
    static let OTHER = "Other"
    static let OTHER_INFORMATION = "OTHER INFORMATION"
    static let PHONE_CONTACTS_WITH_NO_EVENTS = "CONTACTS WITH NO EVENTS"
    static let PHONE_NUMBER = "Phone Number"
    static let PROFILE = "PROFILE"
    static let RECENT = "RECENT"
    static let REMINDERS = "Reminders"
    static let REMOVE = "Remove"
    static let REMOVE_PHOTO = "Remove Photo"
    static let REPORT = "Report"
    static let REQUSETS_RECEIVED = "REQUESTS RECEIVED"
    static let REQUESTS_SENT = "REQUESTS SENT"
    static let RESEND = "RESEND OTP"
    static let RESEND_OTP = "RESEND OTP IN"
    static let RESET = "RESET"
    static let RESET_PASSWORD = "Reset password with"
    static let SAVE = "Save"
    static let SEARCH_WELL_WISHERS = "Search Well Wishers"
    static let SEND_A_WISHIE = "Send a wishie"
    static let SHARE = "Share"
    static let SKIP = "SKIP"
    static let SORT_BY = "SORT BY"
    static let SUGGESTIONS = "SUGGESTIONS"
    static let SUPPORT_THE_APP = "SUPPORT THE APP"
    static let TAKE_PHOTO = "Take Photo"
    static let THIS_WEEK = "this_week"
    static let THIS_MONTH = "later_this_month"
    static let TODAY = "TODAY"
    static let TOMORROW = "TOMORROW"
    static let TONE_EXTENSION = ".mpeg"
    static let TURNED = "Turned"
    static let TURNING = "Turning"
    static let UNBLOCK = "Unblock"
    static let UNFRIEND = "Unfriend"
    static let UNDERAGE_USER = "Underage user"
    static let UPDATE = "Update"
    static let UPLOAD_PHOTO = "Upload Photo"
    static let VERIFIED = "Verified"
    static let WELL_WISHER = "WELL WISHER"
    static let WELL_WISHERS = "WELL-WISHERS"
    static let WISHIE_APPRECIATION = "Appreciation"
    static let WISHIE_BIRTHDAY = "Birthday"
    static let WISHIE_THANK_YOU = "Thank you"
    static let WORK = "Work"
    static let YES = "Yes"
    static let YESTERDAY = "YESTERDAY"
    static let INVITE_FRIEND_TEXT = "Hey,\n\nWishie is an amazing app that I use to celebrate birthdays and much more. Join me on the app. \n\nGet it for free at link for the download"
}

struct Alert {
    static let ALERT = "Alert!"
    static let BLOCK = "Block User"
    static let CANCEL = "Cancel"
    static let CANCEL_REQUEST = "Cancel Request"
    static let CHOOSE_WISHIE = "Choose the wishie:"
    static let COVER_IMAGE = "COVER PHOTO"
    static let CUSTOM_REMINDER = "Custom Reminder"
    static let DELETE = "DELETE!"
    static let DELETE_BIRTHDAY = "Delete Birthday"
    static let DELETE_LABEL = "Delete Label"
    static let ERROR = "Error!"
    static let LOGOUT = "Logout"
    static let OOPS = "Oops!"
    static let PROFILE_IMAGE = "PROFILE PHOTO"
    static let REMOVE_PHOTO = "Remove Photo"
    static let RESET_REMINDERS = "Reset Reminders"
    static let SENT = "Sent"
    static let SUCCESS = "Success!"
    static let UNBLOCK = "Unblock User"
    static let UNFRIEND = "Unfriend User"
}
