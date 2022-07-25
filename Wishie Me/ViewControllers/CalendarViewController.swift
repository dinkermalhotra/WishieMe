import UIKit
import JTAppleCalendar
import SDWebImage

class CalendarCell: JTACDayCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var selectedView: UIView!
}

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblMonth: UILabel!
    
    var currentMonth = 0
    let formatter = DateFormatter()
    var birthdays = [Birthdays]()
    var birthdaysToDisplay = [Birthdays]()
    var leftBarButton = UIBarButtonItem()
    var selectedDate = Date()
    var isToday = true
    
    var calendarDataSource: [String] = []
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage.init(named: "ic_text_header")
        let imageView = UIImageView.init(image: image)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        setupNavigationBar()
        
        calendarView.visibleDates() { visibleDates in
            self.setupMonthLabel(date: visibleDates.monthDates.first!.date)
        }
        calendarView.scrollToDate(Date())
        populateDataSource()
    }
    
    func setupNavigationBar() {
        leftBarButton = UIBarButtonItem.init(title: Strings.TODAY.capitalized, style: .plain, target: self, action: #selector(todayClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_calendar_selected"), style: .plain, target: self, action: #selector(backClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupMonthLabel(date: Date) {
        formatter.dateFormat = "MMM yyyy"
        lblMonth.text = formatter.string(from: date)
    }
    
    func populateDataSource() {
        for birthday in self.birthdays {
            var birthdate = birthday.birthDate
            if birthdate.count > 5 {
                birthdate = String(birthdate.dropFirst(5))
            }
            calendarDataSource.append(birthdate)
        }
        
        calendarView.reloadData()
    }
    
    func handleConfiguration(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        handleCellSelection(cell: cell, cellState: cellState)
    }
    
    func handleCellSelection(cell: CalendarCell, cellState: CellState) {
        birthdaysToDisplay = []
        selectedDate = cellState.date
        if cellState.isSelected {
            cell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
            if Calendar.current.isDateInToday(cellState.date) {
                cell.label.textColor = WishieMeColors.greenColor
            }
            else {
                cell.label.textColor = UIColor.black
            }
            
            cell.selectedView.backgroundColor = WishieMeColors.lightGrayColor
            
            let dateString = dateFormatter.string(from: cellState.date)
            
            for birthday in self.birthdays {
                var birthdate = birthday.birthDate
                if birthdate.count > 5 {
                    birthdate = String(birthdate.dropFirst(5))
                }
                
                if dateString == birthdate {
                    birthdaysToDisplay.append(birthday)
                }
            }
            
            self.tableView.reloadData()
        }
        else {
            if Calendar.current.isDateInToday(cellState.date) {
                cell.label.textColor = WishieMeColors.greenColor
                cell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
            }
            else {
                cell.label.textColor = .black
                cell.label.font = WishieMeFonts.FONT_MONTSERRAT_MEDIUM_16
            }
            cell.selectedView.backgroundColor = .white
        }
    }
    
    func handleCellEvent(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        let dateString = dateFormatter.string(from: cellState.date)
        if calendarDataSource.contains(dateString) {
            cell.dotView.isHidden = false
        }
        else {
            cell.dotView.isHidden = true
        }
    }
    
    func configureVisibleCell(myCustomCell: CalendarCell, cellState: CellState, date: Date, indexPath: IndexPath) {
        if Calendar.current.isDateInToday(date) {
            if isToday {
                isToday = false
                selectedDate = cellState.date
                calendarView.selectDates([date])
                
                myCustomCell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
                myCustomCell.label.textColor = WishieMeColors.greenColor
                myCustomCell.selectedView.backgroundColor = WishieMeColors.lightGrayColor
                
                // Selected Birthday
                let dateString = dateFormatter.string(from: cellState.date)
                
                birthdaysToDisplay = []
                for birthday in self.birthdays {
                    var birthdate = birthday.birthDate
                    if birthdate.count > 5 {
                        birthdate = String(birthdate.dropFirst(5))
                    }
                    
                    if dateString == birthdate {
                        birthdaysToDisplay.append(birthday)
                    }
                }
                
                self.tableView.reloadData()
            }
            else {
                if cellState.dateBelongsTo == .thisMonth {
                    myCustomCell.isHidden = false
                }
                else {
                    myCustomCell.isHidden = true
                }
                
                if cellState.isSelected {
                    myCustomCell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
                    myCustomCell.label.textColor = WishieMeColors.greenColor
                    myCustomCell.selectedView.backgroundColor = WishieMeColors.lightGrayColor
                }
                else {
                    myCustomCell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
                    myCustomCell.label.textColor = WishieMeColors.greenColor
                    myCustomCell.selectedView.backgroundColor = .white
                }
            }
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.isHidden = false
            }
            else {
                myCustomCell.isHidden = true
            }
            
            if cellState.isSelected {
                myCustomCell.label.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
                myCustomCell.label.textColor = UIColor.black
                myCustomCell.selectedView.backgroundColor = WishieMeColors.lightGrayColor
            }
            else {
                myCustomCell.label.font = WishieMeFonts.FONT_MONTSERRAT_MEDIUM_16
                myCustomCell.label.textColor = .black
                myCustomCell.selectedView.backgroundColor = .white
            }
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func todayClicked(_ sender: UIBarButtonItem) {
        isToday = true
        leftBarButton.tintColor = WishieMeColors.greenColor
        calendarView.selectDates([Date()])
        calendarView.scrollToDate(Date())
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
//        if Helper.previousMonthDate(currentMonth) > Helper.previousYearDate() {
//            currentMonth = currentMonth - 1
//            calendarView.scrollToDate(Helper.previousMonthDate(currentMonth))
//        }
//        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
//        if Helper.nextMonthDate(currentMonth + 1) < Helper.nextYearDate() {
//            currentMonth = currentMonth + 1
//            calendarView.scrollToDate(Helper.previousMonthDate(currentMonth))
//        }
//        calendarView.scrollToSegment(.next)
    }
}

// MARK: - UITABLEVIEW METHODS
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if birthdaysToDisplay.count > 0 {
            return birthdaysToDisplay.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if birthdaysToDisplay.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeCell, for: indexPath) as! HomeCell
            
            let value = self.birthdaysToDisplay[indexPath.row]

            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    cell.imgProfile.image = Helper.birthdayImage(value.firstName)
                    return
                }
            }

            if value.friend != nil {
                cell.imgProfile.layer.borderWidth = 1.0
                cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
            }
            else {
                cell.imgProfile.layer.borderWidth = 0
                cell.imgProfile.layer.borderColor = nil
            }
            
            if let url = URL(string: value.image) {
                cell.imgProfile.sd_setImage(with: url, completed: block)
            }
            else {
                cell.imgProfile.image = Helper.birthdayImage(value.firstName)
            }

            cell.lblName.text = "\(value.firstName ) \(value.lastName)"
            cell.lblDaysLeft.text = "\(value.daysLeft )"

            var date = value.birthDate
            var birthdate = value.birthDate
            
            if date.count > 5 {
                date = Helper.shortDateYear(date)
            }
            else {
                date = Helper.shortDate(date)
            }
            
            if let turned = value.turnedAge {
                if birthdate.count > 5 {
                    birthdate = String(birthdate.dropFirst(5))
                }
                
                if birthdate == Helper.tomorrowDate() {
                    cell.lblDays.text = Strings.DAY
                }
                else {
                    cell.lblDays.text = Strings.DAYS
                }
                
                if birthdate == Helper.todayDate() {
                    cell.viewParty.isHidden = false
                    cell.lblAge.text = "\(date) • \(Strings.TURNED) \(turned)"
                }
                else {
                    cell.viewParty.isHidden = true
                    cell.lblAge.text = "\(date) • \(Strings.TURNING) \(turned  + 1)"
                }
            }
            else {
                if birthdate == Helper.todayDate() {
                    cell.viewParty.isHidden = false
                    cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                }
                else {
                    cell.viewParty.isHidden = true
                    cell.lblAge.text = "\(date) • \(Strings.BIRTHDAY)"
                }
            }
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EmptyCell, for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if birthdaysToDisplay.count > 0 {
            let value = birthdaysToDisplay[indexPath.row]
            
            if value.friend != nil {
                if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                    vc.userBirthday = value
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                    vc.userBirthday = self.birthdaysToDisplay[indexPath.row]
                    let navigationController = UINavigationController.init(rootViewController: vc)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeHeaderCell) as! HomeHeaderCell
        
        cell.lblTitle.text = Helper.calendarHeaderDate(selectedDate).uppercased()
        
        return cell
    }
}

// MARK: - JTACCALENDARVIEW
extension CalendarViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CalendarCell
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CellIds.CalendarCell, for: indexPath) as! CalendarCell
        cell.label.text = cellState.text
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthLabel(date: visibleDates.monthDates.first?.date ?? Date())
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let parameter = ConfigurationParameters.init(startDate: Helper.previousYearDate(), endDate: Helper.nextYearDate(), numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        
        return parameter
    }
}
