import UIKit

protocol PushNotificationsDelegate {
    func refreshData()
}

var pushNotificationsDelegate: PushNotificationsDelegate?

class PushNotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var reminders = [Reminders]()
    
    var _settings: SettingsManager?
    
    var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pushNotificationsDelegate = self
        
        setupNavigationBar()
        fetchReminders()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Daily Reminders"
//        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
//        leftBarButton.tintColor = WishieMeColors.darkGrayColor
//        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func addReminder(_ sender: UITapGestureRecognizer) {
        let reminders = self.reminders[sender.view?.tag ?? 0]
        if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
            vc.labelId = reminders.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
//    @IBAction func backClicked(_ sender: UIBarButtonItem) {
//        self.navigationController?.popViewController(animated: true)
//    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    @IBAction func setComplete(_ sender: UISwitch) {
        let reminder = reminders[sender.tag]
        enableDisableReminder(reminder.id, isEnable: NSNumber(value: sender.isOn).intValue)
    }
}

// MARK: - CUSTOM DELEGATE
extension PushNotificationsViewController: PushNotificationsDelegate {
    func refreshData() {
        reminders = []
        fetchReminders()
    }
}

// MARK: - UITABLEVIEW METHODS
extension PushNotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if reminders.count > 0 {
            return self.reminders.count + 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < reminders.count {
            let reminder = reminders[section]
            return reminder.reminders.count + 1
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < reminders.count {
            let reminders = self.reminders[indexPath.section]
            
            if reminders.reminders.count - indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.AddReminderCell)
                
                cell?.contentView.tag = indexPath.section
                cell?.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addReminder(_:))))
                
                return cell ?? UITableViewCell()
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.ReminderCell, for: indexPath)
                
                let reminder = reminders.reminders[indexPath.row]
                cell.textLabel?.text = reminder.title
                cell.detailTextLabel?.text = reminder.time
                
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section < reminders.count {
            let reminders = self.reminders[indexPath.section]
            
            if reminders.reminders.count - indexPath.row != 0 {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reminders = self.reminders[indexPath.section]
        let reminder = reminders.reminders[indexPath.row]
        
        let delete = UITableViewRowAction.init(style: .destructive, title: Strings.DELETE) { (action, index) in
            self.deleteReminder(reminder.id)
            self.tableView.reloadData()
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < reminders.count {
            let reminders = self.reminders[indexPath.section]
            if reminders.reminders.count - indexPath.row != 0 {
                let reminder = reminders.reminders[indexPath.row]
                
                if let vc = ViewControllerHelper.getViewController(ofType: .AddReminderViewController) as? AddReminderViewController {
                    vc.labelId = reminders.id
                    vc.reminderId = reminder.id
                    vc.secondaryLabel = [reminder.title, reminder.time, reminder.tone]
                    vc.titleStr = Strings.EDIT_REMINDER
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else {
            Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.RESET_REMINDERS, message: AlertMessages.RESET_REMINDERS, btnOkTitle: Strings.RESET, btnCancelTitle: Strings.CANCEL, onOk: {
                self.resetReminders()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < reminders.count {
            return 44
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < reminders.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.PushNotificationCell) as! PushNotificationCell
            
            let reminder = reminders[section]
            
            cell.lblTitle.text = "\(reminder.labelName.uppercased()) (\(reminder.birthdayCounts))"
            cell.lblTitle.textColor = UIColor.systemGray
            cell.lblTitle.font = UIFont.systemFont(ofSize: 14)
            
            cell.btnSwitch.tag = section
            if reminder.reminders.count > 0 {
                cell.btnSwitch.isOn = NSNumber.init(value: reminder.reminders[0].isEnable).boolValue
            }
            cell.btnSwitch.addTarget(self, action: #selector(setComplete(_:)), for: .valueChanged)
            
            return cell.contentView
        }
        else {
            return nil
        }
    }
}

// MARK: - API CALLS
extension PushNotificationsViewController {
    func fetchReminders() {
        WSManager.wsCallGetReminders { (isSuccess, message, response) in
            if isSuccess {
                self.reminders = response ?? []
                self.settings?.reminders = response
                self.tableView.reloadData()
            }
            else {
                self.reminders = self.settings?.reminders ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteReminder(_ value: Int) {
        WSManager.wsCallDeleteReminder(value) { (isSuccess, message) in
            if isSuccess {
                self.fetchReminders()
            }
        }
    }
    
    func enableDisableReminder(_ id: Int, isEnable: Int) {
        WSManager.wsCallEnableDisableReminder(id, isEnable) { (isSuccess, message) in
            if isSuccess {
                
            }
        }
    }
    
    func resetReminders() {
        WSManager.wsCallResetReminder { (isSuccess, message) in
            if isSuccess {
                self.fetchReminders()
            }
        }
    }
}
