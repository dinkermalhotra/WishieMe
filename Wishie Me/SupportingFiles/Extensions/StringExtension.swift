import Foundation
import UIKit

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .newlines)
        return components.filter { !$0.isEmpty }.joined(separator: "\n")
    }
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var shortDate: Date? {
        return String.shortDate.date(from: self)
    }
}
