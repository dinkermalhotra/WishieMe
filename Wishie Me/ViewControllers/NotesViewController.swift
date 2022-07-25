import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var imgTick: UIImageView!
    @IBOutlet weak var btnTick: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var lblStartTyping: UILabel!
    
    var userBirthday: Birthdays?
    var recent: RECENT?
    var notes = ""
    var username = ""
    var isFromUserProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if notes.isEmpty || notes == "" {
            imgTick.image = UIImage.init(named: "ic_tick")?.withRenderingMode(.alwaysTemplate)
            imgTick.tintColor = UIColor.officialApplePlaceholderGray
            lblNotes.isHidden = false
            lblStartTyping.isHidden = false
        }
        else {
            imgTick.image = UIImage.init(named: "ic_tick")?.withRenderingMode(.alwaysTemplate)
            imgTick.tintColor = WishieMeColors.greenColor
            lblNotes.isHidden = true
            lblStartTyping.isHidden = true
        }
        
        lblTitle.text = username
        txtNote.text = notes
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        if recent != nil {
            self.updateNotes(birthdayId: recent?.id ?? 0)
        }
        else if userBirthday != nil {
            self.updateNotes(birthdayId: userBirthday?.id ?? 0)
        }
        else {
            createBirthdayViewControllerDelegate?.updatedNote(txtNote.text)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITEXTVIEW DELEGATE
extension NotesViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty {
            lblNotes.isHidden = true
            lblStartTyping.isHidden = true
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty {
            lblNotes.isHidden = false
            lblStartTyping.isHidden = false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            imgTick.image = UIImage.init(named: "ic_tick")?.withRenderingMode(.alwaysTemplate)
            imgTick.tintColor = UIColor.officialApplePlaceholderGray
        }
        else {
            imgTick.image = UIImage.init(named: "ic_tick")?.withRenderingMode(.alwaysTemplate)
            imgTick.tintColor = WishieMeColors.greenColor
        }
    }
}

// MARK: - API CALL
extension NotesViewController {
    func updateNotes(birthdayId: Int = 0) {
        let params: [String: AnyObject] = [WSRequestParams.note: txtNote.text as AnyObject]
        WSManager.wsCallEditBirthday(params, birthdayId) { (isSuccess, message) in
            if isSuccess {
                if self.recent != nil {
                    self.recent?.note = self.txtNote.text
                }
                else if self.userBirthday != nil {
                    self.userBirthday?.note = self.txtNote.text
                }
                
                userProfileNotAvailableDelegate?.updateBirthdayDetails()
                homeViewControllerDelegate?.refreshData()
                labelsViewControllerDelegate?.refreshLabels()
                
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
