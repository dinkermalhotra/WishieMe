import UIKit
import SDWebImage

class LabelMoveViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var birthdaysInLabel = [Birthdays]()
    var birthdays = [Birthdays]()
    var filteredBirthdays = [Birthdays]()
    var labels = [Labels]()
    var idsToMove = [Int]()
    var labelName = ""
    var labelId: Int = 0
    var selectedTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        fetchBirthdays()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Add to \(labelName)"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.boldSystemFont(ofSize: 16)]
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
//        let leftBarButton = UIBarButtonItem.init(title: Strings.NEW, style: .plain, target: self, action: #selector(newClicked(_:)))
//        leftBarButton.tintColor = WishieMeColors.greenColor
//        leftBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
//        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem.init(title: Strings.DONE, style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .CreateBirthdayViewController) as? CreateBirthdayViewController {
            vc.labelId = labelId
            vc.labelName = labelName
            let navigationController = UINavigationController.init(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if idsToMove.count > 0 {
            moveBirthdays()
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func selectionClicked(_ sender: UIButton) {
        let indexPath = IndexPath.init(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? LabelMoveCell {
            
            for birthday in birthdays {
                let id = "\(birthday.id)"
                
                if id == cell.textLabel?.text ?? "" {
                    birthday.isSelected = !birthday.isSelected
                    
                    if idsToMove.contains(birthday.id) {
                        for i in 0..<idsToMove.count {
                            if birthday.id == idsToMove[i] {
                                idsToMove.remove(at: i)
                                break
                            }
                        }
                    }
                    else {
                        idsToMove.append(birthday.id)
                    }
                }
            }
            
            self.tableView.reloadData()
        }
    }
}

// MARK: - UISEARCHBAR DELEGATE
extension LabelMoveViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.birthdays = filteredBirthdays.filter {
                $0.firstName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                $0.lastName.range(of: searchBar.text ?? "", options: [.caseInsensitive, .diacriticInsensitive ]) != nil
            }
            
            self.tableView.reloadData()
        }
        else {
            self.birthdays = self.filteredBirthdays
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension LabelMoveViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.LabelMoveCell, for: indexPath) as! LabelMoveCell
        
        let dict = birthdays[indexPath.row]
        
        if dict.friend != nil {
            cell.imgProfile.layer.borderWidth = 1.0
            cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
        }
        else {
            cell.imgProfile.layer.borderWidth = 0
            cell.imgProfile.layer.borderColor = nil
        }

        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                cell.imgProfile.image = Helper.birthdayImage(dict.firstName)
                return
            }
        }

        if let url = URL(string: dict.image) {
            cell.imgProfile.sd_setImage(with: url, completed: block)
        }
        else {
            cell.imgProfile.image = Helper.birthdayImage(dict.firstName)
        }
        
        cell.lblName.text = "\(dict.firstName) \(dict.lastName)"
        cell.textLabel?.text = "\(dict.id)"
        cell.textLabel?.isHidden = true
        
        cell.btnSelection.isSelected = dict.isSelected
        cell.btnSelection.tag = indexPath.row
        cell.btnSelection.addTarget(self, action: #selector(selectionClicked(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - API CALL
extension LabelMoveViewController {
    func fetchBirthdays() {
        WSManager.wsCallGetBirthdays { (isSuccess, message, response) in
            if var response = response {
                for birthday in self.birthdaysInLabel {
                    if let index = response.firstIndex(where: { $0.id == birthday.id }) {
                        response.remove(at: index)
                    }
                }
                
                self.birthdays = response
                self.filteredBirthdays = response
                
                self.tableView.reloadData()
            }
        }
    }
    
    func moveBirthdays() {
        let params: [String: AnyObject] = [WSRequestParams.labelId: labelId as AnyObject,
                                           WSRequestParams.birthdays: idsToMove as AnyObject]
        WSManager.wsCallMoveBirthdays(params) { (isSuccess, message) in
            if isSuccess {
                labelsViewControllerDelegate?.refreshLabelAndManageUser(self.selectedTag)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
