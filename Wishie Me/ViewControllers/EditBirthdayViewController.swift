import UIKit

class EditBirthdayViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var birthday = ""
    var day = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Birthday"
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditBirthdayViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.EditBirthdayCell, for: indexPath) as! EditBirthdayCell
        
        cell.lblDob.text = birthday
        cell.lblDay.text = "It was a \(day)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "You are not allowed to change your birthday as we believe you are only born once in this lifetime.\n\nIf you have mistakenly entered a wrong birthday while creating your profile, kindly write to us at \(WebService.reportProblemMail)"
    }
}
