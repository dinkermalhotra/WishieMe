import UIKit

@objc protocol TextViewCellDelegate: class {
    @objc optional func textViewDidBeginEditing(_ textView: UITextView?, for indexPath: IndexPath?)
    
    @objc optional func textViewDidChange(_ textView: UITextView?, for indexPath: IndexPath?)
    
    @objc optional func textViewTableViewCellDoneTyping(_ textView: UITextView?, for indexPath: IndexPath?)
    
    @objc optional func shouldChangeEditTextCellText(_ cell: TextViewCell?, newText: String?) -> Bool
}

class TextViewCell: UITableViewCell, UITextViewDelegate {
        
    @IBOutlet var textView: UITextView!
    
    weak var delegate: TextViewCellDelegate?
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
        
        textView.delegate = self
        textView.inputAccessoryView = keyboardToolbar
    }
    
    @objc func doneTyping() {
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.textViewDidBeginEditing?(self.textView, for: indexPath)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.textViewDidChange?(self.textView, for: indexPath)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewTableViewCellDoneTyping?(self.textView, for: indexPath)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Get the new text.
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if textView.text.count >= 140 && newText.count >= 140 {
            return false
        }
        
        // Ask the delegate if the text is valid.
        if let shouldChangeEditTextCellText = self.delegate?.shouldChangeEditTextCellText?(self, newText: newText) {
            return shouldChangeEditTextCellText
        }
        
        return true
    }
}
