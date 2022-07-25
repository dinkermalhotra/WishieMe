import UIKit

class PickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dates: [Int]?
    var monthsWithDays: [String]?
    var months: [String]?
    var years: [Int]?
    var currentYear = 22
    
    var date = Calendar.current.component(.day, from: Date()) {
        didSet {
            selectRow(dates?.firstIndex(of: date) ?? 0, inComponent: 0, animated: false)
        }
    }
    
    var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            selectRow(month - 1, inComponent: 1, animated: false)
        }
    }
    
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            selectRow(years?.firstIndex(of: year) ?? 0, inComponent: 2, animated: true)
        }
    }
    
    var isYearHidden: Bool?
    var isEdit: Bool?
    var isYearEmbedded: Bool?
    var onDateSelected: ((_ date: Int, _ month: Int, _ year: Int) -> Void)?
    var onDateSelect: ((_ date: Int, _ month: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        // population dates
        var date: [Int] = []
        
        if date.count == 0 {
            for i in 1...31 {
                date.append(i)
            }
        }
        
        self.dates = date
        
        // population years
        var years: [Int] = []
        if years.count == 0 {
            let year = Calendar.current.component(.year, from: Date())
            
            for i in 1...year {
                years.append(i)
            }
        }
        self.years = years
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        if isEdit ?? false {
            self.selectRow(dates?.firstIndex(of: self.date) ?? 0, inComponent: 0, animated: false)
            self.selectRow(self.month - 1, inComponent: 1, animated: false)

            if !(isYearHidden ?? false) {
                if isYearEmbedded ?? true {
                    self.selectRow(years.firstIndex(of: self.year) ?? 0, inComponent: 2, animated: false)
                }
                else {
                    self.selectRow(years.count - currentYear, inComponent: 2, animated: false)
                }
            }
        }
        else {
            self.selectRow(dates?.firstIndex(of: self.date) ?? 0, inComponent: 0, animated: false)
            self.selectRow(self.month - 1, inComponent: 1, animated: false)

            if !(isYearHidden ?? false) {
                self.selectRow(years.count - currentYear, inComponent: 2, animated: false)
            }
        }
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isYearHidden ?? false {
            return 2
        }
        else {
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isYearHidden ?? false {
            switch component {
            case 0:
                return "\(dates?[row] ?? 0)"
            case 1:
                return months?[row]
            default:
                return nil
            }
        }
        else {
            switch component {
            case 0:
                return "\(dates?[row] ?? 0)"
            case 1:
                return months?[row]
            case 2:
                return "\(years?[row] ?? 0)"
            default:
                return nil
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isYearHidden ?? false {
            switch component {
            case 0:
                return dates?.count ?? 0
            case 1:
                return months?.count ?? 0
            default:
                return 0
            }
        }
        else {
            switch component {
            case 0:
                return dates?.count ?? 0
            case 1:
                return months?.count ?? 0
            case 2:
                return years?.count ?? 0
            default:
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDate()
    }
    
    func selectedDate() {
        let date = self.selectedRow(inComponent: 0)+1
        let month = self.selectedRow(inComponent: 1)+1
        
        if isYearHidden ?? false {
            updateDates(month)
            
            if let block = onDateSelect {
                block(date, month)
            }
            
            self.date = date
            self.month = month
        }
        else {
            let year = years?[self.selectedRow(inComponent: 2)]
            
            futureDates(month, year ?? 2020)
            
            if let block = onDateSelected {
                block(date, month, year ?? 0)
            }
            
            self.date = date
            self.month = month
            self.year = year ?? 0
        }
    }
    
    func futureDates(_ getMonth: Int, _ getYear: Int) {
        let calendar = Calendar.current
        let dateComponent = calendar.dateComponents([.day, .month, .year], from: Date())
        let currentDay = dateComponent.day ?? 10
        let currentMonth = dateComponent.month ?? 12
        let currentYear = dateComponent.year ?? 2020
        
        // population date & months with localized names
        var date: [Int] = []
        var months: [String] = []
        var month = 0
        
        if currentMonth <= getMonth && currentYear <= getYear {
            for i in 1...currentDay {
                date.append(i)
            }
            
            for _ in 1...currentMonth {
                months.append(DateFormatter().monthSymbols[month].capitalized)
                month += 1
            }
        }
        else {
            if getMonth == 1 || getMonth == 3 || getMonth == 5 || getMonth == 7 || getMonth == 8 || getMonth == 10 || getMonth == 12 {
                for i in 1...31 {
                    date.append(i)
                }
            }
            else if getMonth == 2 {
                if self.year % 4 == 0 {
                    for i in 1...29 {
                        date.append(i)
                    }
                }
                else {
                    for i in 1...28 {
                        date.append(i)
                    }
                }
            }
            else {
                for i in 1...30 {
                    date.append(i)
                }
            }
            
            for _ in 1...12 {
                months.append(DateFormatter().monthSymbols[month].capitalized)
                month += 1
            }
        }
        
        self.dates = date
        self.months = months
        
        self.reloadComponent(0)
        self.reloadComponent(1)
    }
    
    func updateDates(_ month: Int) {
        var date: [Int] = []
        
        if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
            for i in 1...31 {
                date.append(i)
            }
        }
        else if month == 2 {
            if self.year % 4 == 0 {
                for i in 1...29 {
                    date.append(i)
                }
            }
            else {
                for i in 1...28 {
                    date.append(i)
                }
            }
        }
        else {
            for i in 1...30 {
                date.append(i)
            }
        }
        
        self.dates = date
        
        self.reloadComponent(0)
    }
}
