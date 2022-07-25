import UIKit

class DaysViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var days = ["Day of Occasion", "1 Day Before", "2 Days Before", "3 Days Before", "4 Days Before", "5 Days Before", "6 Days Before", "1 Week Before", "2 Weeks Before", "3 Weeks Before", "4 Weeks Before"]
    
    var selectedValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Reminder Date"
        self.navigationController?.navigationBar.tintColor = WishieMeColors.greenColor
    }

}

// MARK: - UITABLEVIEW METHODS
extension DaysViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.DaysCell, for: indexPath)
        
        cell.textLabel?.text = days[indexPath.row]
        if selectedValue == days[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        addReminderViewControllerDelegate?.selectedDay(days[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
