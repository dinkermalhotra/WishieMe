import UIKit

class EditLastNameCell: UITableViewCell {

    @IBOutlet weak var txtLastName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtLastName.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - UITEXTFIELD EXTENSION
extension EditLastNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
