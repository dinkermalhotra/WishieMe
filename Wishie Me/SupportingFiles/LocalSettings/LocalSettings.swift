import UIKit

class LocalSettings: NSObject
{
    static var isEditBirthday: Bool?
    static var isCustomReminder: Bool?
    
    class func clearIsEditBirthday() {
        isEditBirthday = nil
    }
    
    class func clearIsCustomReminder() {
        isCustomReminder = nil
    }
}
