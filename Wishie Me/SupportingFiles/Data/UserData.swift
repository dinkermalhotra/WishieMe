import UIKit
import PhoneNumberKit

class UserData: NSObject
{
    static var accessToken: String?
    static var appleId: String?
    static var dateOfBirth: String?
    static var email: String?
    static var facebookId: String?
    static var firstName: String?
    static var gender: String?
    static var gmailId: String?
    static var homeViewType: String?
    static var imageUrl: URL?
    static var isSocialLogin: Bool?
    static var lastName: String?
    static var password: String?
    static var phoneNumber: String?
    static var twitterId: String?
    static var userId: Int?
    static var userName: String?
    
    class func clear()
    {
        accessToken = ""
        appleId = ""
        email = ""
        facebookId = ""
        firstName = ""
        gender = ""
        gmailId = ""
        homeViewType = ""
        imageUrl = nil
        isSocialLogin = nil
        lastName = ""
        password = ""
        phoneNumber = ""
        twitterId = ""
        userId = nil
        userName = ""
    }
}

class PhoneNumberRecognition: NSObject {    
    @objc static func parseNumber(_ number: String) -> String {
        do {
            let phoneNumber = try PhoneNumberKit().parse(number, ignoreType: true)
            return "+\(phoneNumber.countryCode)"
        } catch let error {
            print(error.localizedDescription)
            return error.localizedDescription
        }
    }
}
