import UIKit

class BirthdayViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtBirthday: UITextField!
    
    var rightBarButton = UIBarButtonItem()
    lazy var addingDoneToolBarTOKeyboard: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action:#selector(self.btnDoneOfToolBarPressed))
        doneButton.tintColor = UIColor.black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupName()
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(title: Strings.NEXT, style: .plain, target: self, action: #selector(nextClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupName() {
        if UserData.firstName != nil {
            lblName.text = "\(Strings.HELLO) \(UserData.firstName ?? "")"
        }
        
        if UserData.dateOfBirth != nil {
            txtBirthday.text = UserData.dateOfBirth
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func btnDoneOfToolBarPressed() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func textFieldEditingBegin(_ sender: UITextField) {
        lblName.text = Strings.BIRTHDAY
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        sender.inputView = datePickerView
        sender.inputAccessoryView = addingDoneToolBarTOKeyboard
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        self.txtBirthday.text = dateFormatter.string(from: sender.date)
        rightBarButton.tintColor = WishieMeColors.greenColor
        UserData.dateOfBirth = Helper.convertDateOfBirth(txtBirthday.text ?? "")
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if !(txtBirthday.text?.isEmpty ?? true) {
            if let vc = ViewControllerHelper.getViewController(ofType: .GenderViewController) as? GenderViewController {
                UserData.dateOfBirth = txtBirthday.text
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
