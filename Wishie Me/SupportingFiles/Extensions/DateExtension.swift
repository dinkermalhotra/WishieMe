import UIKit

extension Date {
    func getWeekDates() -> (thisWeek:[Date], nextWeek:[Date]) {
        var tuple: (thisWeek:[Date], nextWeek:[Date])
        var arrThisWeek: [Date] = []
        for i in 0..<7 {
            arrThisWeek.append(Calendar.current.date(byAdding: .day, value: i, to: startOfWeek) ?? Date())
        }
        
        var arrNextWeek: [Date] = []
        for i in 1...7 {
            arrNextWeek.append(Calendar.current.date(byAdding: .day, value: i, to: arrThisWeek.last ?? Date()) ?? Date())
        }
        tuple = (thisWeek: arrThisWeek, nextWeek: arrNextWeek)
        return tuple
    }
    
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return Date()}
        return gregorian.date(byAdding: .day, value: 1, to: sunday) ?? Date()
    }
}
