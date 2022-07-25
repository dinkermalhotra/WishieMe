import Foundation
import UIKit

class Validator: NSObject {
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    static func validateLowercase(_ string: String) -> UIColor {
        let lowerLetterRegex  = ".*[a-z]+.*"
        let lowerLetterTest = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegex)
        
        return lowerLetterTest.evaluate(with: string) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
    }
    
    static func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "(?!.* )(?=.*[A-Z])(?=.*[0-9])(?=.*[!&^%$#@*_])(?=.*[a-z]).{8,}"
        let passwordTest = NSPredicate.init(format: "SELF MATCHES %@", passwordRegex)
        
        return passwordTest.evaluate(with: password)
    }
    
    static func validateNumber(_ string: String) -> UIColor {
        let numberRegex  = ".*[0-9]+.*"
        let numberTest = NSPredicate(format:"SELF MATCHES %@", numberRegex)
        
        return numberTest.evaluate(with: string) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
    }
    
    static func validateSpecialCharacter(_ string: String) -> UIColor {
        let specialCharacterRegex  = ".*[!&^%$#@*_]+.*"
        let specialCharacterTest = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegex)
        
        return specialCharacterTest.evaluate(with: string) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
    }
    
    static func validateUppercase(_ string: String) -> UIColor {
        let capitalLetterRegex  = ".*[A-Z]+.*"
        let capitalLetterTest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegex)
        
        return capitalLetterTest.evaluate(with: string) == true ? WishieMeColors.greenColor : WishieMeColors.darkGrayColor
    }
}
