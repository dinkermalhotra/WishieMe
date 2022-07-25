import UIKit

class EditFirstNameCell: UITableViewCell {

    @IBOutlet weak var txtFirstName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtFirstName.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - UITEXTFIELD EXTENSION
extension EditFirstNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
