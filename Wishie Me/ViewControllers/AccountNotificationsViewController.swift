import UIKit

class AccountNotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var pushTitles = ["I receive an ADD request", "My contacts join", "Someone accepts my request"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Account Notifications"
    }

}

// MARK: - UITABLEVIEWMETHODS
extension AccountNotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.PushNotificationCell) as! PushNotificationCell
        
        cell.lblTitle.text = pushTitles[indexPath.row]
        
        return cell
    }
}
