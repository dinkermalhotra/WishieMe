import UIKit

class EditBioViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var lblCharacterCount: UILabel!
    
    let FREEFORM_CELL_HEIGHT = 60.0
    let HORIZONTAL_PADDING = 30
    let VERTICAL_PADDING = 20
    
    var rightBarButton = UIBarButtonItem()
    var bio = ""
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        tableView.tableFooterView = footerView
        lblCharacterCount.text = "\(bio.count)/140"
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Bio"
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if !bio.isEmpty && rightBarButton.tintColor != UIColor.officialApplePlaceholderGray {
            editBio()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension EditBioViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.TextViewCell, for: indexPath) as! TextViewCell
        
        cell.textView.text = bio
        cell.delegate = self
        cell.textView.returnKeyType = .done
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.TextViewCell) as! TextViewCell
        
        cell.textView.text = bio
        
        let fixedWidthInst = view.frame.size.width - CGFloat(HORIZONTAL_PADDING)
        let newSizeInst = cell.textView.sizeThatFits(CGSize(width: fixedWidthInst, height: CGFloat(MAXFLOAT)))
        
        return newSizeInst.height + CGFloat(VERTICAL_PADDING)
    }
}

// MARK: - TEXTVIEWCELL DELEGATE
extension EditBioViewController: TextViewCellDelegate {
    func shouldChangeEditTextCellText(_ cell: TextViewCell?, newText: String?) -> Bool {
        bio = newText ?? ""
        
        if bio.isEmpty {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
        else {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        
        if let cell = cell {
            tableView.beginUpdates()
            tableView.endUpdates()
            if let indexPath = tableView.indexPath(for: cell) {
                let cell = tableView.cellForRow(at: indexPath) as? TextViewCell
                
                if let height = cell?.frame.size.height {
                    if Double(height) > FREEFORM_CELL_HEIGHT {
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
            
            lblCharacterCount.text = "\(bio.count)/140"
        }
        
        return true
    }
}

// MARK: - API CALL
extension EditBioViewController {
    func editBio() {
        let params: [String: AnyObject] = [WSRequestParams.bio: bio as AnyObject]
        WSManager.wsCallEditProfile(params) { (isSuccess, message, response) in
            var data: [AnyHashable: Any] = [:]
            data[UPDATE_PROFILE] = response
            self.notifier.send(NOTIFICATION_UPDATE_PROFILE, withData: data)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
