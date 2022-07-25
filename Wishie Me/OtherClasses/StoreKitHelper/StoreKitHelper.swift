import Foundation
import StoreKit

struct StoreKitHelper {
    static let numberOfTimesLaunchedKey = "numberOfTimesLaunched"
    
    static func displayStoreKit() {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else { return }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersion")
        let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey)
        
        if numberOfTimesLaunched > 2 && currentVersion != lastVersionPromptedForReview {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    static func incrementNumberOfTimesLaunched() {
        let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey) + 1
        UserDefaults.standard.set(numberOfTimesLaunched, forKey: StoreKitHelper.numberOfTimesLaunchedKey)
    }
}
