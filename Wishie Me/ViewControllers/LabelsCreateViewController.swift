import UIKit

class LabelsCreateViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgLabel: UIImageView!
    
    var colors = ["FFE959", "FDBD5D", "FF8200", "C6A730", "A4FFBB", "C9E265", "58B430", "008037", "FA6C6C", "FF1616", "C74375", "A26948", "FFACEC", "FF1D9B", "D103D1", "8C52FF", "7DE4FF", "3FB8FF", "5271FF", "004AAD"]
    var isLabelEdit = false
    var labelId: Int = 0
    var labelName = ""
    var rightBarButton = UIBarButtonItem()
    var selectedColor = ""
    var originalColor = ""
    var isFromHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "New Label"
        setupNavigationBar()
        
        if isLabelEdit {
            txtName.text = labelName
            imgLabel.tintColor = UIColor.init(hex: selectedColor.replacingOccurrences(of: "#", with: ""))
        }
    }
        
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_cross"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = UIColor.red
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_tick"), style: .plain, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
        
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        if !(sender.text?.isEmpty ?? true) && !selectedColor.isEmpty {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if !(txtName.text?.isEmpty ?? true) && !originalColor.isEmpty {
            if isLabelEdit {
                editLabel()
            }
            else {
                if txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == Strings.FAMILY.lowercased() || txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == Strings.FRIENDS.lowercased() || txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == Strings.WORK.lowercased() {
                    Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.LABEL_NAME_EXIST)
                }
                else {
                    createLabel()
                }
            }
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension LabelsCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if labelId == 2 || labelId == 3 || labelId == 4 {
            return false
        }
        
        return true
    }
}

// MARK: - UICOLLECTIONVIEW METHODS
extension LabelsCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.LabelsCreateCell, for: indexPath) as! LabelsCreateCell
        
        DispatchQueue.main.async {
            cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
            cell.colorView.layer.borderColor = UIColor.black.cgColor
            cell.colorView.layer.borderWidth = 0.5
            cell.colorView.clipsToBounds = true
            
            if self.isLabelEdit {
                if self.selectedColor.replacingOccurrences(of: "#", with: "") == self.colors[indexPath.row] {
                    cell.colorView.layer.borderWidth = 3
                }
            }
        }
        
        cell.colorView.backgroundColor = UIColor.init(hex: colors[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        if let cell = collectionView.cellForItem(at: indexPath) as? LabelsCreateCell {
            cell.colorView.layer.borderWidth = 3
        }
        
        selectedColor = "#\(colors[indexPath.row])"
        originalColor = selectedColor
        imgLabel.tintColor = UIColor.init(hex: colors[indexPath.row])
        
        if !(txtName.text?.isEmpty ?? true) && !selectedColor.isEmpty {
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
        else {
            rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LabelsCreateCell {
            cell.colorView.layer.borderWidth = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width / 6.1, height: collectionView.frame.size.width / 6.1)
    }
}

// MARK : - API CALL
extension LabelsCreateViewController {
    func createLabel() {
        let params: [String: AnyObject] = [WSRequestParams.labelName: txtName.text as AnyObject,
                                           WSRequestParams.labelColor: selectedColor as AnyObject]
        WSManager.wsCallCreateLabels(params) { (isSuccess, message, labels)  in
            if isSuccess {
                // Refresh labels on home
                homeViewControllerDelegate?.refreshLabels()
                
                // Refresh labels
                labelsViewControllerDelegate?.refreshLabels()
                
                if self.isFromHome {                    
                    if let vc = ViewControllerHelper.getViewController(ofType: .LabelsViewController) as? LabelsViewController {
                        vc.isFromHome = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
    
    func editLabel() {
        let params: [String: AnyObject] = [WSRequestParams.labelName: txtName.text as AnyObject,
                                           WSRequestParams.labelColor: selectedColor as AnyObject]
        WSManager.wsCallEditLabels(params, labelId) { (isSuccess, message) in
            if isSuccess {
                // Refresh labels on home
                homeViewControllerDelegate?.refreshLabels()
                
                // Refresh labels
                labelsViewControllerDelegate?.refreshLabels()
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: message)
            }
        }
    }
}
