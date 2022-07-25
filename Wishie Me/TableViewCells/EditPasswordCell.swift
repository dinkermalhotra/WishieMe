import UIKit

@objc protocol TextFieldCellDelegate: class {
    @objc optional func textFieldDidBeginEditing(_ textField: UITextField?, for indexPath: IndexPath?)
    
    @objc optional func textFieldDidChange(_ textField: UITextField?, for indexPath: IndexPath?)
    
    @objc optional func textFieldTableViewCellDoneTyping(_ textField: UITextField?, for indexPath: IndexPath?)
    
    @objc optional func shouldChangeEditTextCellText(_ cell: EditPasswordCell?, _ tag: Int, newText: String?) -> Bool
}

class EditPasswordCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowPassword: UIButton!
    
    weak var delegate: TextFieldCellDelegate?
    var indexPath: IndexPath?
    
    var keyboardToolbar: UIToolbar {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))

        // Use this space to right align the button.
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [flexibleSpace, keyboardToolbarDone]
        
        return keyboardToolbar
    }
    
    var keyboardToolbarDone: UIBarButtonItem {
        let keyboardToolbarDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTyping))
        
        return keyboardToolbarDone
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtPassword.delegate = self
        txtPassword.inputAccessoryView = keyboardToolbar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func doneTyping() {
        txtPassword.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidBeginEditing?(textField, for: indexPath)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.delegate?.textFieldDidChange?(textField, for: indexPath)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidBeginEditing?(textField, for: indexPath)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the new text.
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        // Ask the delegate if the text is valid.
        if let shouldChangeEditTextCellText = self.delegate?.shouldChangeEditTextCellText?(self, textField.tag, newText: newText) {
            return shouldChangeEditTextCellText
        }

        return true
    }
}
