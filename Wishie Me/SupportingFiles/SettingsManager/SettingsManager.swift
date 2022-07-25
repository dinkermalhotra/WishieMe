import UIKit
import ObjectMapper

protocol SettingsManagerProtocol: AnyObject
{
    var accessToken: String
    {
        get set
    }
    
    var email: String
    {
        get set
    }
    
    var firstName: String
    {
        get set
    }
    
    var lastName: String
    {
        get set
    }
    
    var lastTabIndex: Int
    {
        get set
    }
    
    var phone: String
    {
        get set
    }
    
    var profileImage: String
    {
        get set
    }
    
    var userId: Int
    {
        get set
    }
    
    var username: String
    {
        get set
    }
    
    // Local Storage
    
    var birthdays: [Birthdays]?
    {
        get set
    }
    
    var blockedUser: [UserProfile]?
    {
        get set
    }
    
    var friends: [UserProfile]?
    {
        get set
    }
    
    var labels: [Labels]?
    {
        get set
    }
    
    var notifications: Data?
    {
        get set
    }
    
    var profile: Profile?
    {
        get set
    }
    
    var recents: [RECENT]?
    {
        get set
    }
    
    var reminders: [Reminders]?
    {
        get set
    }
    
    var sendToMe: [UserProfile]?
    {
        get set
    }
    
    var sentByMe: [UserProfile]?
    {
        get set
    }
    
    func synchronize()
}

class SettingsManager: NSObject, SettingsManagerProtocol
{

    let SETTING_ACCESS_TOKEN = "SETTING_ACCESS_TOKEN"
    let SETTING_EMAIL = "SETTING_EMAIL"
    let SETTING_FIRST_NAME = "SETTING_FIRST_NAME"
    let SETTING_LAST_NAME = "SETTING_LAST_NAME"
    let SETTING_LAST_TAB_INDEX = "SETTING_LAST_TAB_INDEX"
    let SETTING_PHONE = "SETTING_PHONE"
    let SETTINGS_PROFILE_IMAGE = "SETTINGS_PROFILE_IMAGE"
    let SETTING_USER_NAME = "SETTING_USER_NAME"
    let SETTING_USER_ID = "SETTING_USER_ID"
    
    // Local storage
    let SETTING_BLOCKED_USER = "SETTING_BLOCKED_USER"
    let SETTING_FRIENDS = "SETTING_FRIENDS"
    let SETTING_LABELS = "SETTING_LABELS"
    let SETTING_HOME_BIRTHDAYS = "SETTING_HOME_BIRTHDAYS"
    let SETTING_HOME_RECENT = "SETTING_HOME_RECENT"
    let SETTING_NOTIFICATIONS = "SETTING_NOTIFICATIONS"
    let SETTING_PROFILE = "SETTING_PROFILE"
    let SETTING_REMINDERS = "SETTING_REMINDERS"
    let SETTING_SEND_TO_ME = "SETTING_SEND_TO_ME"
    let SETTING_SENT_BY_ME = "SETTING_SENT_BY_ME"

    private var _defaults: UserDefaults?
    private var defaults: UserDefaults
    {
        if let _defaults = _defaults {
            return _defaults
        }
        else {
            _defaults = UserDefaults.standard
        }

        return _defaults ?? UserDefaults.standard
    }

    var accessToken: String
    {
        get
        {
            return defaults.value(forKey: SETTING_ACCESS_TOKEN) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_ACCESS_TOKEN)
        }
    }
    
    var email: String
    {
        get
        {
            return defaults.value(forKey: SETTING_EMAIL) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_EMAIL)
        }
    }
    
    var firstName: String
    {
        get
        {
            return defaults.value(forKey: SETTING_FIRST_NAME) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_FIRST_NAME)
        }
    }
    
    var lastName: String
    {
        get
        {
            return defaults.value(forKey: SETTING_LAST_NAME) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_LAST_NAME)
        }
    }
    
    var lastTabIndex: Int
    {
        get
        {
            return defaults.value(forKey: SETTING_LAST_TAB_INDEX) as? Int ?? 0
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_LAST_TAB_INDEX)
        }
    }
    
    var phone: String
    {
        get
        {
            return defaults.value(forKey: SETTING_PHONE) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_PHONE)
        }
    }
    
    var profileImage: String
    {
        get
        {
            return defaults.value(forKey: SETTINGS_PROFILE_IMAGE) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTINGS_PROFILE_IMAGE)
        }
    }
    
    var userId: Int
    {
        get
        {
            return defaults.value(forKey: SETTING_USER_ID) as? Int ?? 0
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_USER_ID)
        }
    }
    
    var username: String
    {
        get
        {
            return defaults.value(forKey: SETTING_USER_NAME) as? String ?? ""
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_USER_NAME)
        }
    }

    var birthdays: [Birthdays]?
    {
        get
        {
            if let birthday = defaults.value(forKey: SETTING_HOME_BIRTHDAYS) as? String {
                if let data = birthday.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<Birthdays>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_HOME_BIRTHDAYS)
        }
    }
    
    var blockedUser: [UserProfile]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_BLOCKED_USER) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<UserProfile>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_BLOCKED_USER)
        }
    }
    
    var friends: [UserProfile]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_FRIENDS) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<UserProfile>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_FRIENDS)
        }
    }
    
    var labels: [Labels]?
    {
        get
        {
            if let label = defaults.value(forKey: SETTING_LABELS) as? String {
                if let data = label.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<Labels>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_LABELS)
        }
    }
    
    var notifications: Data?
    {
        get
        {
            if let notification = defaults.value(forKey: SETTING_NOTIFICATIONS) as? Data {
                return notification
            }
            
            return nil
        }
        set
        {
            defaults.set(newValue, forKey: SETTING_NOTIFICATIONS)
        }
    }
    
    var profile: Profile?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_PROFILE) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            return Mapper<Profile>().map(JSON: dictionary) as Profile?
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return nil
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_PROFILE)
        }
    }
    
    var recents: [RECENT]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_HOME_RECENT) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<RECENT>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_HOME_RECENT)
        }
    }
    
    var reminders: [Reminders]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_REMINDERS) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<Reminders>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_REMINDERS)
        }
    }
    
    var sendToMe: [UserProfile]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_SEND_TO_ME) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<UserProfile>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_SEND_TO_ME)
        }
    }
    
    var sentByMe: [UserProfile]?
    {
        get
        {
            if let recent = defaults.value(forKey: SETTING_SENT_BY_ME) as? String {
                if let data = recent.data(using: .utf8) {
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            return Mapper<UserProfile>().mapArray(JSONArray: dictionary)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            return []
        }
        set
        {
            defaults.set(newValue?.description, forKey: SETTING_SENT_BY_ME)
        }
    }
    
    func synchronize()
    {
        defaults.synchronize()
    }
}

