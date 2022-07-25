import UIKit

protocol AddReminderViewControllerDelegate {
    func selectedDay(_ value: String)
    func selectedTone(_ value: String)
}

var addReminderViewControllerDelegate: AddReminderViewControllerDelegate?

class AddReminderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var datePickerIndexPath: IndexPath?
    var labelId = 0
    var reminderId: Int?
    var birthdayId: Int?
    var inputDates: [Date] = []
    var textLabel = ["Date", "Time"]
    var secondaryLabel = ["Day of Occasion", "10:00 AM"]
    var titleStr = "Add Reminder"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addInitailValues()
        addReminderViewControllerDelegate = self
        setupNavigationBar()
    }
    
    func addInitailValues() {
//        if titleStr == Strings.EDIT_REMINDER {
//            inputDates = Array(repeating: Helper.convertTimeToDate(secondaryLabel[1]), count: 3)
//        }
//        else {
//            inputDates = Array(repeating: "10:00 AM", count: 3)
//        }
        inputDates = Array(repeating: Helper.convertTimeToDate(secondaryLabel[1]), count: 3)
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = titleStr
        let cancelButton = UIBarButtonItem.init(title: Strings.CANCEL, style: .plain, target: self, action: #selector(cancelClicked(_:)))
        cancelButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem.init(title: Strings.SAVE, style: .plain, target: self, action: #selector(saveClicked(_:)))
        saveButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveClicked(_ sender: UIBarButtonItem) {
        Helper.showLoader(onVC: self)
        if LocalSettings.isCustomReminder ?? false {
            if reminderId != nil {
                editCustomReminder()
            }
            else {
                addCustomReminder()
            }
        }
        else {
            if reminderId != nil {
                self.editReminder(reminderId ?? 0)
            }
            else {
                self.addReminder()
            }
        }
    }
}

// MARK: - CUSTOM DELEGATE
extension AddReminderViewController: AddReminderViewControllerDelegate {
    func selectedDay(_ value: String) {
        self.secondaryLabel.remove(at: 0)
        self.secondaryLabel.insert(value, at: 0)
        self.tableView.reloadData()
    }
    
    func selectedTone(_ value: String) {
        self.secondaryLabel.remove(at: 2)
        self.secondaryLabel.insert(value, at: 2)
        self.tableView.reloadData()
    }
}

// MARK: - UITABLEVIEW METHODS
extension AddReminderViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if reminderId != nil {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reminderId != nil {
            if section == 0 {
                if datePickerIndexPath != nil {
                    return textLabel.count + 1
                }
                else {
                    return textLabel.count
                }
            }
            else {
                return 1
            }
        }
        else {
            if datePickerIndexPath != nil {
                return textLabel.count + 1
            }
            else {
                return textLabel.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if reminderId != nil {
            if indexPath.section == 0 {
                if datePickerIndexPath == indexPath {
                    let datePickerCell = tableView.dequeueReusableCell(withIdentifier: CellIds.DatePickerCell, for: indexPath) as! DatePickerCell
                    datePickerCell.updateCell(date: inputDates[indexPath.row - 1], indexPath: indexPath)
                    datePickerCell.delegate = self
                    
                    return datePickerCell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.ReminderCell, for: indexPath)
                
                    cell.textLabel?.text = textLabel[indexPath.row]
                    cell.detailTextLabel?.text = secondaryLabel[indexPath.row].replacingOccurrences(of: Strings.TONE_EXTENSION, with: "")
                
                    cell.accessoryType = .disclosureIndicator
                    cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
                    
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.RemoveReminderCell, for: indexPath)
                
                return cell
            }
        }
        else {
            if datePickerIndexPath == indexPath {
                let datePickerCell = tableView.dequeueReusableCell(withIdentifier: CellIds.DatePickerCell, for: indexPath) as! DatePickerCell
                datePickerCell.updateCell(date: inputDates[indexPath.row - 1], indexPath: indexPath)
                datePickerCell.delegate = self
                
                return datePickerCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.ReminderCell, for: indexPath)
            
                cell.textLabel?.text = textLabel[indexPath.row]
                cell.detailTextLabel?.text = secondaryLabel[indexPath.row].replacingOccurrences(of: Strings.TONE_EXTENSION, with: "")
            
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = UIImageView(image: UIImage(named: "ic_next"))
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if datePickerIndexPath == indexPath {
            return 162
        }
        else {
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reminderId != nil {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    tableView.beginUpdates()
                    if let datePickerIndexPath = datePickerIndexPath {
                        tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                        self.datePickerIndexPath = nil
                    }
                    tableView.endUpdates()
                    
                    if let vc = ViewControllerHelper.getViewController(ofType: .DaysViewController) as? DaysViewController {
                        vc.selectedValue = secondaryLabel[0]
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else if indexPath.row == 1 {
                    tableView.beginUpdates()
                    if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
                        tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                        self.datePickerIndexPath = nil
                    } else {
                        if let datePickerIndexPath = datePickerIndexPath {
                            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                        }
                        datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                        tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    tableView.endUpdates()
                }
                else {
                    tableView.beginUpdates()
                    if let datePickerIndexPath = datePickerIndexPath {
                        tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                        self.datePickerIndexPath = nil
                    }
                    tableView.endUpdates()
                    
                    if let vc = ViewControllerHelper.getViewController(ofType: .TonesViewController) as? TonesViewController {
                        vc.selectedValue = secondaryLabel[2].replacingOccurrences(of: Strings.TONE_EXTENSION, with: "")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            else {
                if LocalSettings.isCustomReminder ?? false {
                    deleteCustomReminder()
                }
                else {
                    self.deleteReminder()
                }
            }
        }
        else {
            if indexPath.row == 0 {
                tableView.beginUpdates()
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                    self.datePickerIndexPath = nil
                }
                tableView.endUpdates()
                
                if let vc = ViewControllerHelper.getViewController(ofType: .DaysViewController) as? DaysViewController {
                    vc.selectedValue = secondaryLabel[0]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.row == 1 {
                tableView.beginUpdates()
                if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                    self.datePickerIndexPath = nil
                } else {
                    if let datePickerIndexPath = datePickerIndexPath {
                        tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                    }
                    datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                    tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                tableView.endUpdates()
            }
            else {
                tableView.beginUpdates()
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                    self.datePickerIndexPath = nil
                }
                tableView.endUpdates()
                
                if let vc = ViewControllerHelper.getViewController(ofType: .TonesViewController) as? TonesViewController {
                    vc.selectedValue = secondaryLabel[2].replacingOccurrences(of: Strings.TONE_EXTENSION, with: "")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - DATEPICKER DELEGATE
extension AddReminderViewController: DatePickerDelegate {
    func didChangeDate(date: Date, indexPath: IndexPath) {
        secondaryLabel.remove(at: 1)
        secondaryLabel.insert(Helper.updateTime(date), at: 1)
        inputDates[indexPath.row] = date
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - API CALL
extension AddReminderViewController {
    func addReminder() {
        var daysBefore = ""
        if secondaryLabel[0] == "Day of Occasion" {
            daysBefore = "0 day before"
        }
        else {
            daysBefore = secondaryLabel[0].lowercased()
        }
        
        let params: [String: AnyObject] = [WSRequestParams.labelId: labelId as AnyObject,
                                           WSRequestParams.title: secondaryLabel[0] as AnyObject,
                                           WSRequestParams.daysBefore: daysBefore as AnyObject,
                                           WSRequestParams.time: secondaryLabel[1] as AnyObject,
                                           WSRequestParams.tone: "default_sound.mpeg" as AnyObject]
        WSManager.wsCallCreateReminder(params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                pushNotificationsDelegate?.refreshData()
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func addCustomReminder() {
        var daysBefore = ""
        if secondaryLabel[0] == "Day of Occasion" {
            daysBefore = "0 day before"
        }
        else {
            daysBefore = secondaryLabel[0].lowercased()
        }
        
        let params: [String: AnyObject] = [WSRequestParams.title: secondaryLabel[0] as AnyObject,
                                           WSRequestParams.daysBefore: daysBefore as AnyObject,
                                           WSRequestParams.time: secondaryLabel[1] as AnyObject,
                                           WSRequestParams.tone: "default_sound.mpeg" as AnyObject]
        WSManager.wsCallCreateBirthdayReminder(birthdayId ?? 0, params) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                LocalSettings.clearIsCustomReminder()
                userProfileNotAvailableDelegate?.refreshData()
                friendProfileViewControllerDelegate?.refreshData()
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func editCustomReminder() {
        var daysBefore = ""
        var tone = ""
        if secondaryLabel[0] == "Day of Occasion" {
            daysBefore = "0 day before"
        }
        else {
            daysBefore = secondaryLabel[0].lowercased()
        }
        
        if secondaryLabel[2].contains(Strings.TONE_EXTENSION) {
            tone = secondaryLabel[2]
        }
        else {
            tone = "\(secondaryLabel[2])\(Strings.TONE_EXTENSION)"
        }
        
        let params: [String: AnyObject] = [WSRequestParams.title: secondaryLabel[0] as AnyObject,
                                           WSRequestParams.daysBefore: daysBefore as AnyObject,
                                           WSRequestParams.time: secondaryLabel[1] as AnyObject,
                                           WSRequestParams.tone: "default_sound.mpeg" as AnyObject]
        WSManager.wsCallEditBirthdayReminder(params, reminderId ?? 0) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                LocalSettings.clearIsCustomReminder()
                userProfileNotAvailableDelegate?.refreshData()
                friendProfileViewControllerDelegate?.refreshData()
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func editReminder(_ value: Int) {
        var daysBefore = ""
        var tone = ""
        
        if secondaryLabel[0] == "Day of Occasion" {
            daysBefore = "0 day before"
        }
        else {
            daysBefore = secondaryLabel[0].lowercased()
        }
        
        if secondaryLabel[2].contains(Strings.TONE_EXTENSION) {
            tone = secondaryLabel[2]
        }
        else {
            tone = "\(secondaryLabel[2])\(Strings.TONE_EXTENSION)"
        }
        
        let params: [String: AnyObject] = [WSRequestParams.labelId: labelId as AnyObject,
                                           WSRequestParams.title: secondaryLabel[0] as AnyObject,
                                           WSRequestParams.daysBefore: daysBefore as AnyObject,
                                           WSRequestParams.time: secondaryLabel[1] as AnyObject,
                                           WSRequestParams.tone: "default_sound.mpeg" as AnyObject]
        WSManager.wsCallEditReminder(params, value) { (isSuccess, message) in
            Helper.hideLoader(onVC: self)
            if isSuccess {
                pushNotificationsDelegate?.refreshData()
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func deleteCustomReminder() {
        WSManager.wsCallDeleteBirthdayReminder(reminderId ?? 0) { (isSuccess, message) in
            if isSuccess {
                if isSuccess {
                    LocalSettings.clearIsCustomReminder()
                    userProfileNotAvailableDelegate?.refreshData()
                    friendProfileViewControllerDelegate?.refreshData()
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
                }
            }
        }
    }
    
    func deleteReminder() {
        WSManager.wsCallDeleteReminder(reminderId ?? 0) { (isSuccess, message) in
            if isSuccess {
                pushNotificationsDelegate?.refreshData()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
