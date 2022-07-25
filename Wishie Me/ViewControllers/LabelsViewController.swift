import UIKit
import SDWebImage

protocol LabelsViewControllerDelegate {
    func refreshLabels()
    func refreshLabelAndManageUser(_ selectedTag: Int)
}
var labelsViewControllerDelegate: LabelsViewControllerDelegate?

class LabelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var labels = [Labels]()
    var storedOffsets = [Int: CGFloat]()
    var selectedTag = 0
    var isFromHome = false
    
    var _settings: SettingsManager?
    
    var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelsViewControllerDelegate = self
        if isFromHome {
            setupNavigationBarToHome()
        }
        else {
            setupNavigationBar()
        }
        
        fetchLabels()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "My Labels"
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_plus"), style: .plain, target: self, action: #selector(newLabelClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupNavigationBarToHome() {
        self.navigationItem.title = "My Labels"
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_plus"), style: .plain, target: self, action: #selector(newLabelClicked(_:)))
        rightBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func manageLabel() {
        let dict = labels[selectedTag]
        if let vc = ViewControllerHelper.getViewController(ofType: .ManageUsersViewController) as? ManageUsersViewController {
            vc.birthdays = dict.birthdays
            vc.filteredBirthdays = dict.birthdays
            vc.labelName = dict.labelName
            vc.labelId = dict.id
            vc.selectedTag = selectedTag
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func editLabel() {
        let dict = labels[selectedTag]
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelsCreateViewController) as? LabelsCreateViewController {
            vc.isLabelEdit = true
            vc.labelId = dict.id
            vc.labelName = dict.labelName
            vc.selectedColor = dict.labelColor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func deleteLabel() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.DELETE_LABEL, message: AlertMessages.DELETE_LABEL, btnOkTitle: Strings.DELETE, btnCancelTitle: Strings.CANCEL, onOk: {
            let dict = self.labels[self.selectedTag]
            self.deleteLabels(dict.id)
        })
    }
    
    func emptyLabel() {
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.ALERT, message: AlertMessages.EMPTY_LABEL, btnOkTitle: Strings.YES, btnCancelTitle: Strings.NO, onOk: {
            let dict = self.labels[self.selectedTag]
            self.emptyLabel(dict.id)
        })
    }
    
    func reminders() {
        if let vc = ViewControllerHelper.getViewController(ofType: .PushNotificationsViewController) as? PushNotificationsViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        for controller in (self.navigationController?.viewControllers ?? [UIViewController]()) {
            if controller.isKind(of: HomeViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func newLabelClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .LabelsCreateViewController) as? LabelsCreateViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func labelClicked(_ sender: UIButton) {
        selectedTag = sender.tag
        let dict = labels[selectedTag]
        
        if sender.tag > 2 {
            //Helper.showFiveOptionsActionAlert(onVC: self, title: dict.labelName.uppercased(), titleOne: Strings.MANAGE, actionOne: manageLabel, titleTwo: Strings.EDIT, actionTwo: editLabel, titleThree: Strings.REMINDERS, actionThree: reminders, titleFour: Strings.CLEAR, actionFour: emptyLabel, titleFive: Strings.DELETE, actionFive: deleteLabel)
            Helper.showFourOptionsActionAlert(onVC: self, title: dict.labelName.uppercased(), titleOne: Strings.MANAGE, actionOne: manageLabel, titleTwo: Strings.EDIT, actionTwo: editLabel, titleThree: Strings.REMINDERS, actionThree: reminders, titleFour: Strings.DELETE, actionFour: deleteLabel, styleType: .destructive)
        }
        else {
            //Helper.showFourOptionsActionAlert(onVC: self, title: dict.labelName.uppercased(), titleOne: Strings.MANAGE, actionOne: manageLabel, titleTwo: Strings.EDIT, actionTwo: editLabel, titleThree: Strings.REMINDERS, actionThree: reminders, titleFour: Strings.CLEAR, actionFour: emptyLabel, styleType: .default)
            Helper.showThreeWishieOptionActionAlert(onVC: self, title: dict.labelName.uppercased(), titleOne: Strings.MANAGE, actionOne: manageLabel, titleTwo: Strings.EDIT, actionTwo: editLabel, titleThree: Strings.REMINDERS, actionThree: reminders, actionCancel: {
                
            }, styleType: .default)
        }
    }
    
    @IBAction func manageLabelCkicked(_ sender: UIButton) {
        selectedTag = sender.tag
        manageLabel()
    }
}

// MARK: - UITABLEVIEW METHODS
extension LabelsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.HomeRecentCell, for: indexPath) as! HomeRecentCell
        
        let birthdays = labels[indexPath.section]
        
        if birthdays.birthdays.count > 0 {
            cell.collectionView.isHidden = false
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
            cell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
        }
        else {
            cell.collectionView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = labels[indexPath.section]
        
        if dict.birthdays.count == 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .LabelMoveViewController) as? LabelMoveViewController {
                vc.labelName = dict.labelName
                vc.labelId = dict.id
                vc.selectedTag = selectedTag
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .overFullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? HomeRecentCell else { return }
        storedOffsets[indexPath.section] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.LabelsCell) as! LabelsCell
        
        let dict = labels[section]
        let color = UIColor.init(hex: dict.labelColor.replacingOccurrences(of: "#", with: ""))
        
        cell.lblName.text = "\(dict.labelName.uppercased()) (\(dict.birthdayCounts))"
        cell.imgColor.tintColor = color
        cell.btnManage.tintColor = color
        cell.btnManage.tag = section
        cell.btnLabel.tag = section
        cell.btnManage.addTarget(self, action: #selector(labelClicked(_:)), for: .touchUpInside)
        cell.btnLabel.addTarget(self, action: #selector(manageLabelCkicked(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - UICOLLECTIONVIEW METHODS
extension LabelsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tag = collectionView.tag
        let birthdays = labels[tag]
        return birthdays.birthdays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.HomeRecentCollectionCell, for: indexPath) as! HomeRecentCollectionCell
        
        let tag = collectionView.tag
        let birthdays = labels[tag]
        let value = birthdays.birthdays[indexPath.row]
        
        DispatchQueue.main.async {
            if value.friend != nil {
                cell.imgProfile.layer.borderWidth = 1.0
                cell.imgProfile.layer.borderColor = WishieMeColors.greenColor.cgColor
            }
            else {
                cell.imgProfile.layer.borderWidth = 0
                cell.imgProfile.layer.borderColor = nil
            }
            
            cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height / 2
            cell.imgProfile.clipsToBounds = true
        }

        // IMAGE
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            if (image == nil) {
                cell.imgProfile.image = Helper.birthdayImage(value.firstName)
                return
            }
        }

        if let url = URL(string: value.image) {
            cell.imgProfile.sd_setImage(with: url, completed: block)
        }
        else {
            cell.imgProfile.image = Helper.birthdayImage(value.firstName)
        }

        // NAME
        cell.lblname.text = value.firstName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = collectionView.tag
        let birthdays = labels[tag]
        let value = birthdays.birthdays[indexPath.row]
        
        if value.friend != nil {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                vc.userBirthday = value
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileNotAvailableController) as? UserProfileNotAvailableController {
                vc.userBirthday = value
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = WishieMeColors.greenColor
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - LABELS DELEGATE
extension LabelsViewController: LabelsViewControllerDelegate {
    func refreshLabels() {
        labels = []
        fetchLabels()
    }
    
    func refreshLabelAndManageUser(_ selectedTag: Int) {
        labels = []
        WSManager.wsCallGetLabels { (isSuccess, message, response) in
            if isSuccess {
                self.labels = response ?? []
                self.tableView.reloadData()
                
                let dict = self.labels[selectedTag]
                manageUsersDelegate?.refreshData(dict.birthdays)
            }
        }
    }
}

// MARK: - API CALL
extension LabelsViewController {
    func fetchLabels() {
        WSManager.wsCallGetLabels { (isSuccess, message, response) in
            if isSuccess {
                self.labels = response ?? []
                self.settings?.labels = response ?? []
                self.tableView.reloadData()
            }
            else {
                if message == AlertMessages.NO_INTERNET {
                    Helper.showToast(onVC: self)
                }
                
                self.labels = self.settings?.labels ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteLabels(_ id: Int) {
        WSManager.wsCallDeleteLabels(id) { (isSuccess, message) in
            if isSuccess {
                homeViewControllerDelegate?.refreshData()
                homeViewControllerDelegate?.refreshLabels()
                self.fetchLabels()
            }
        }
    }
    
    func emptyLabel(_ id: Int) {
        WSManager.wsCallEmptylabel(id) { (isSuccess, message) in
            if isSuccess {
                self.fetchLabels()
            }
        }
    }
}
