import UIKit
import SDWebImage

protocol UserProfileViewControllerDelegate {
    func refreshData()
}

var userProfileViewControllerDelegate: UserProfileViewControllerDelegate?

class UserProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgZodiac: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDateOfBirth: UILabel!
    @IBOutlet weak var lblWishies: UILabel!
    @IBOutlet weak var lblBio: ExpandableLabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnBio: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var ifNotFromTab = false
    var _settings: SettingsManager?
    var userProfile: Profile?
    var sent = [Videos]()
    var received = [Videos]()
    var states = true
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
                
        userProfileViewControllerDelegate = self
        setupNavigationBar()
        setupNotificationManager()
        
        fetchProfile()
        
        lblWishies.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(wellWishersClicked(_:))))
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2, height: AppConstants.PORTRAIT_SCREEN_WIDTH / 3.2)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settings?.lastTabIndex = 4
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNavBar()
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func removeNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupNavigationBar() {
        if ifNotFromTab {
            let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back_background"), style: .plain, target: self, action: #selector(backClicked(_:)))
            self.navigationItem.leftBarButtonItem = backButton
            
            btnBio.isHidden = true
        }
        else {
            let settings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_setting"), style: .plain, target: self, action: #selector(settingsClicked(_:)))
            self.navigationItem.rightBarButtonItem = settings
            
            btnBio.isHidden = false
        }
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateData(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PROFILE), object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendToDraft(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SEND_TO_DRAFT), object: nil)
    }
    
    @objc func sendToDraft(_ notification: Notification) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SavedWishieViewController) as? SavedWishieViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func updateData(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let userProfile = notificationUserInfo[UPDATE_PROFILE] as? Profile {
                self.userProfile = userProfile
                self.setData(userProfile)
            }
        }
    }
    
    // MARK: - UIBUTON ACTIONS
    
    @IBAction func addBioClicked(_ sender: UIButton) {
        if let vc = ViewControllerHelper.getViewController(ofType: .EditProfileViewController) as? EditProfileViewController {
            vc.userProfile = userProfile
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SettingsViewController) as? SettingsViewController {
            vc.userProfile = userProfile
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.collectionView.reloadData()
        
        //CGFloat height = collectionView.collectionViewLayout.collectionViewContentSize.height
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint.constant = height
        self.view.setNeedsLayout()
        //self.view.layoutIfNeeded()
    }
    
    @IBAction func wellWishersClicked(_ sender: UITapGestureRecognizer) {
        if userProfile?.friendsCount != nil || userProfile?.friendsCount != 0 {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendsViewController) as? FriendsViewController {
                vc.userProfile = userProfile
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - EXPANDEDLABEL DELEGATE
extension UserProfileViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        states = false
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        states = true
    }
    
    func preparedSources(_ bio: String) -> (text: String, textReplacementType: ExpandableLabel.TextReplacementType, numberOfLines: Int, textAlignment: NSTextAlignment) {
        return (bio, .character, 3, .left)
    }
}

// MARK: - CUSTOM DELEGATE
extension UserProfileViewController: UserProfileViewControllerDelegate {
    func refreshData() {
        fetchProfile()
    }
}

// MARK: - UICOLLECTIONVIEW METHODS
extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return self.received.count
        }
        else {
            return self.sent.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.SavedWishieCell, for: indexPath) as! SavedWishieCell
        
        if segmentControl.selectedSegmentIndex == 0 {
            let dict = received[indexPath.row]
            
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    return
                }
            }

            if let url = URL(string: dict.videoThumbnail) {
                cell.imgPreview.sd_setImage(with: url, completed: block)
            }
        }
        else {
            let dict = sent[indexPath.row]
            
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    return
                }
            }

            if let url = URL(string: dict.videoThumbnail) {
                cell.imgPreview.sd_setImage(with: url, completed: block)
            }
        }
        
        return cell
    }
}

// MARK: - API CALL
extension UserProfileViewController {
    func fetchProfile() {
        WSManager.wsCallGetProfile { (isSuccess, message, response) in
            if isSuccess {
                self.userProfile = response
                self.settings?.profile = response
            }
            else {
                if message == AlertMessages.NO_INTERNET {
                    Helper.showToast(onVC: self)
                }
                
                self.userProfile = self.settings?.profile
            }
            
            self.setData(self.userProfile)
        }
    }
    
    func setData(_ profile: Profile?) {
        //titleView(profile)
        let zodiacDate = Helper.convertedDateForZodiacSign(profile?.dob ?? "")
        lblName.text = "\(profile?.firstName ?? "") \(profile?.lastName ?? "")"
        lblDateOfBirth.text = "\(Helper.calcAge(profile?.dob ?? ""))y • \(profile?.dob ?? "") • \(Helper.getZodiacSign(zodiacDate))"
        imgZodiac.image = Helper.getZodiacSignImages(zodiacDate)
        
        //let wellWishers = (profile?.friendsCount ?? 0 > 1) ? Strings.WELL_WISHERS.capitalized : Strings.WELL_WISHER.capitalized
        lblWishies.text = "\(profile?.friendsCount ?? 0) \(Strings.WELL_WISHERS.capitalized)"
        lblUsername.text = "@\(profile?.username ?? "")"
        
        let currentSource = self.preparedSources((profile?.bio ?? "").condenseWhitespace())
        lblBio.delegate = self
        lblBio.setLessLinkWith(lessLink: "less", attributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: WishieMeColors.darkGrayColor], position: .left)
        lblBio.shouldCollapse = true
        lblBio.textReplacementType = currentSource.textReplacementType
        lblBio.numberOfLines = currentSource.numberOfLines
        lblBio.collapsed = self.states
        lblBio.text = currentSource.text
        
        // profile image
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgProfile.image = Helper.birthdayImage(profile?.firstName ?? "")
                return
            }
        }
        
        let urlStr = profile?.profileImage ?? ""
        let urlString:String = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString as String)
        
        imgProfile.sd_setImage(with: url, completed: block)
        
        // haeader image
        let headerBlock: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                self.imgHeader.image = UIImage(named: "img_user_profile")
                return
            }
        }
        
        let headerUrlStr = profile?.headerImage ?? ""
        let headerUrlString:String = headerUrlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headerUrl = URL(string: headerUrlString as String)
        
        imgHeader.sd_setImage(with: headerUrl, completed: headerBlock)
        
        if let wishieReceived = profile?.wishieReceived {
            self.received = wishieReceived
        }
        
        if let wishieSent = profile?.wishieSent {
            self.sent = wishieSent
        }
        
        self.collectionView.reloadData()
    }
    
    func titleView(_ profile: Profile?) {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = WishieMeFonts.FONT_MONTSERRAT_MEDIUM_16 ?? UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "\(profile?.username ?? "")    "
        label.backgroundColor = UIColor.white
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        self.navigationItem.titleView = label
    }
}
