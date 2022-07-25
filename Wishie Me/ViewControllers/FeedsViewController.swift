import UIKit
import SDWebImage

protocol FeedsViewControllerDelegate {
    func reloadData()
    func reloadCell(_ textView: UITextView, _ comment: Comments?)
    func textViewDidBeginEditing(_ textView: UITextView)
}

var feedsViewControllerDelegate: FeedsViewControllerDelegate?

class FeedsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    
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
    
    var activeTextView: UITextView?
    var videos = [Videos]()
    var index: Int?
    var selectedButton: UIButton?
    var textViewTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedsViewControllerDelegate = self
        setNavigationBar()
        setupNotificationManager()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchFeeds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        settings?.lastTabIndex = 1
        pausePlayeVideos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.view.endEditing(true)
        self.tableView.endEditing(true)
    }
    
    func setNavigationBar() {
        self.navigationItem.title = "Celebrations"
        let searchBarButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchClicked(_:)))
        searchBarButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = searchBarButton
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.fetchFeeds()
    }
    
    @IBAction func searchClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SearchFriendViewController) as? SearchFriendViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func pausePlayeVideos() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
    
    func share() {
        let dict = videos[index ?? 0]
        
        let items: [Any] = [dict.video]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    func report() {
        
    }
    
    @objc func sendToDraft(_ notification: Notification) {
        if let vc = ViewControllerHelper.getViewController(ofType: .SavedWishieViewController) as? SavedWishieViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appEnteredFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendToDraft(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SEND_TO_DRAFT), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        
        if let userInfo = userInfo {
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if AppConstants.PORTRAIT_SCREEN_HEIGHT > 736 && AppConstants.PORTRAIT_SCREEN_HEIGHT < 1024  {
                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 40, right: 0)
                    tableView.contentInset = contentInsets
                }
                else {
                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 8, right: 0)
                    tableView.contentInset = contentInsets
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        
        if self.selectedButton != nil {
            self.hideOrShowCommentBox(self.selectedButton ?? UIButton())
        }
        else {
            let indexPath = IndexPath.init(row: self.activeTextView?.tag ?? 0, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
                if self.activeTextView == cell.txtCommentFrom {
                    cell.btnCloseFrom.isHidden = true
                }
                
                if self.activeTextView == cell.txtCommentTo {
                    cell.btnCloseTo.isHidden = true
                }
            }
            
            feedsCellDelegate?.emptyText()
        }
    }
    
    @objc func lblUserToClicked(_ sender: UITapGestureRecognizer) {
        let dict = videos[sender.view?.tag ?? 0]
        
        if dict.sharedWith?.id == settings?.userId {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileViewController) as? UserProfileViewController {
                vc.ifNotFromTab = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                vc.user = dict.sharedWith
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func lblUserFromClicked(_ sender: UITapGestureRecognizer) {
        let dict = videos[sender.view?.tag ?? 0]
        
        if dict.whoShared?.id == settings?.userId {
            if let vc = ViewControllerHelper.getViewController(ofType: .UserProfileViewController) as? UserProfileViewController {
                vc.ifNotFromTab = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let vc = ViewControllerHelper.getViewController(ofType: .FriendProfileViewController) as? FriendProfileViewController {
                vc.user = dict.whoShared
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func hideOrShowCommentBox(_ sender: UIButton) {        
        let dict = videos[sender.tag]
        guard let value = Int(sender.accessibilityValue ?? "0") else { return }
        let comment = dict.comments?[value]

        tableView.beginUpdates()
        if sender.isSelected {
            sender.isSelected = false
            
            let indexPath = IndexPath(row: sender.tag, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
                if comment?.userId == comment?.publisherId {
                    cell.btnDeleteCommentFrom.isHidden = false
                    
                    cell.txtCommentFrom.isUserInteractionEnabled = false
                    cell.txtCommentFrom.text = comment?.comment
                    cell.txtCommentFrom.resignFirstResponder()
                }
                else {
                    cell.btnDeleteCommentTo.isHidden = false
                    
                    cell.txtCommentTo.isUserInteractionEnabled = false
                    cell.txtCommentTo.text = comment?.comment
                    cell.txtCommentTo.resignFirstResponder()
                }
            }
        }
        else {
            sender.isSelected = true
            
            let indexPath = IndexPath(row: sender.tag, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
                if comment?.userId == comment?.publisherId {
                    cell.btnDeleteCommentFrom.isHidden = true
                    
                    cell.txtCommentFrom.isUserInteractionEnabled = true
                    cell.txtCommentFrom.becomeFirstResponder()
                }
                else {
                    cell.btnDeleteCommentTo.isHidden = true
                    
                    cell.txtCommentTo.isUserInteractionEnabled = true
                    cell.txtCommentTo.becomeFirstResponder()
                }
            }
        }
        tableView.endUpdates()
    }
    
    func deleteComment(_ sender: UIButton) {
        let dict = videos[sender.tag]
        guard let value = Int(sender.accessibilityValue ?? "0") else { return }
        let comment = dict.comments?[value]
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.ALERT, message: AlertMessages.DELETE_COMMENT, btnOkTitle: Strings.YES, btnCancelTitle: Strings.NO, onOk: {
            self.deleteComment(comment?.id ?? 0)
            
            dict.comments?.remove(at: value)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        })
    }
    
    func crossClicked(_ sender: UIButton) {
        sender.isHidden = !sender.isHidden
        
        tableView.beginUpdates()
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
            if self.activeTextView == cell.txtCommentFrom {
                cell.txtCommentFrom.text = ""
                cell.txtCommentFrom.resignFirstResponder()
            }
            
            if self.activeTextView == cell.txtCommentTo {
                cell.txtCommentTo.text = ""
                cell.txtCommentTo.resignFirstResponder()
            }
        }
        tableView.endUpdates()
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func closeCommentFrom(_ sender: UIButton) {
        crossClicked(sender)
    }
    
    @IBAction func closeCommentTo(_ sender: UIButton) {
        crossClicked(sender)
    }
    
    @IBAction func deleteCommentFromClicked(_ sender: UIButton) {
        self.deleteComment(sender)
    }
    
    @IBAction func deleteCommentToClicked(_ sender: UIButton) {
        self.deleteComment(sender)
    }
    
    @IBAction func editCommentFromClicked(_ sender: UIButton) {
        self.selectedButton = sender
        self.hideOrShowCommentBox(sender)
    }
    
    @IBAction func editCommentToClicked(_ sender: UIButton) {
        self.selectedButton = sender
        self.hideOrShowCommentBox(sender)
    }
    
    @IBAction func favouriteClicked(_ sender: UIButton) {
        let dict = videos[sender.tag]
        dict.isFavourite = !dict.isFavourite
        
        self.saveToWishie(dict.id, dict.userId)
        
        self.tableView.reloadData()
    }
    
    @IBAction func likedClicked(_ sender: UIButton) {
        let dict = videos[sender.tag]
        dict.didILike = !dict.didILike
        
        if dict.didILike {
            dict.likeCounts += 1
        }
        else {
            dict.likeCounts -= 1
        }
        
        self.likeVideo(dict.id)
        
        self.tableView.reloadData()
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        index = sender.tag
        Helper.showActionAlert(onVC: self, title: nil, titleOne: Strings.SHARE, actionOne: share, titleTwo: Strings.REPORT, actionTwo: report, styleOneType: .default, styleTwoType: .destructive)
    }
    
    @IBAction func shareWishieClicked(_ sender: UIButton) {
        index = sender.tag
        share()
    }
}

// MARK: - CUSTOM DELEGATE
extension FeedsViewController: FeedsViewControllerDelegate {    
    func reloadData() {
        DispatchQueue.main.async {
            self.fetchFeeds()
        }
    }
    
    func reloadCell(_ textView: UITextView, _ comment: Comments?) {
        tableView.beginUpdates()
        let dict = videos[textView.tag]
        
        if dict.comments?.count != 2 {
            if comment?.userId == settings?.userId {
                dict.comments?.append(comment ?? Comments())
            }
        }
        
        let indexPath = IndexPath(row: textView.tag, section: 0)
        
        if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
            for i in 0..<(dict.comments?.count ?? 0) {
                let comment = dict.comments?[i]
                
                if comment?.userId == settings?.userId {
                    if comment?.userId == comment?.publisherId {
                        cell.btnEditCommentFrom.isSelected = false
                        
                        comment?.comment = cell.txtCommentFrom.text ?? ""
                        cell.txtCommentFrom.resignFirstResponder()
                    }
                    else {
                        cell.btnEditCommentTo.isSelected = false
                        
                        comment?.comment = cell.txtCommentTo.text ?? ""
                        cell.txtCommentTo.resignFirstResponder()
                    }
                }
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        tableView.endUpdates()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let indexPath = IndexPath.init(row: textView.tag, section: 0)

        if let cell = tableView.cellForRow(at: indexPath) as? FeedsCell {
            if cell.txtCommentFrom.isUserInteractionEnabled && cell.btnEditCommentFrom.isHidden {
                cell.btnCloseFrom.isHidden = false
                self.activeTextView = cell.txtCommentFrom
            }

            if cell.txtCommentTo.isUserInteractionEnabled && cell.btnCloseTo.isHidden {
                cell.btnCloseTo.isHidden = false
                self.activeTextView = cell.txtCommentTo
            }
        }
    }
}

// MARK: - UISCROLLVIEW DELEGATE
extension FeedsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
}

// MARK: - UITABLEVIEW METHODS
extension FeedsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.FeedsCell, for: indexPath) as! FeedsCell
        
        let dict = videos[indexPath.row]
        
        // Set thumbnail and video
        cell.videoId = dict.id
        cell.configureCell(imageUrl: dict.videoThumbnail, videoUrl: dict.video)
        
        // Set user images
        let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
            //print(image)
            if (image == nil) {
                return
            }
        }

        if let url = URL(string: dict.whoShared?.profileImage ?? "") {
            cell.imgUserFrom.sd_setImage(with: url, completed: block)
            cell.imgCommentFrom.sd_setImage(with: url, completed: block)
        }
        
        if let url = URL(string: dict.sharedWith?.profileImage ?? "") {
            cell.imgUserTo.sd_setImage(with: url, completed: block)
            cell.imgCommentTo.sd_setImage(with: url, completed: block)
        }

        // Set wishie images
        if dict.typeOfWishie == Strings.WISHIE_APPRECIATION {
            cell.imgTypeOfWishie.image = #imageLiteral(resourceName: "ic_appreciation")
        }
        else if dict.typeOfWishie == Strings.WISHIE_THANK_YOU {
            cell.imgTypeOfWishie.image = #imageLiteral(resourceName: "ic_thankYou")
        }
        else {
            cell.imgTypeOfWishie.image = #imageLiteral(resourceName: "ic_cake")
        }
        
        // Hide views to support delete comment
        if dict.sharedWith?.id == settings?.userId {
            cell.viewCommentTo.isHidden = false
            cell.btnEditCommentTo.isHidden = true
            cell.btnCloseTo.isHidden = true
            cell.btnDeleteCommentTo.isHidden = true
            
            cell.lblCommentToTime.text = ""
            cell.txtCommentTo.text = ""
        }
        
        if dict.whoShared?.id == settings?.userId {
            cell.viewCommentFrom.isHidden = false
            cell.btnEditCommentFrom.isHidden = true
            cell.btnCloseFrom.isHidden = true
            cell.btnDeleteCommentFrom.isHidden = true
            
            cell.lblCommentFromTime.text = ""
            cell.txtCommentFrom.text = ""
        }
        
        for i in 0..<(dict.comments?.count ?? 0) {
            let comment = dict.comments?[i]
            
            if comment?.publisherId == comment?.userId {
                cell.viewCommentFrom.isHidden = false
                cell.txtCommentFrom.isUserInteractionEnabled = false
                
                cell.btnEditCommentFrom.accessibilityValue = String(i)
                cell.btnDeleteCommentFrom.accessibilityValue = String(i)
                cell.btnCloseFrom.accessibilityValue = String(i)
                
                cell.txtCommentFrom.text = comment?.comment ?? ""
                cell.lblCommentFromTime.text = Helper.timeZoneDate(comment?.updatedAt ?? "")
            }
            
            if comment?.publisherId != comment?.userId {
                cell.viewCommentTo.isHidden = false
                cell.txtCommentTo.isUserInteractionEnabled = false
                
                cell.btnEditCommentTo.accessibilityValue = String(i)
                cell.btnDeleteCommentTo.accessibilityValue = String(i)
                cell.btnCloseTo.accessibilityValue = String(i)
                
                cell.txtCommentTo.text = comment?.comment ?? ""
                cell.lblCommentToTime.text = Helper.timeZoneDate(comment?.updatedAt ?? "")
            }
            
            // show edit & delete Button based on user comment
            if comment?.userId == settings?.userId && comment?.publisherId == settings?.userId {
                cell.btnEditCommentFrom.isSelected = false
                cell.btnDeleteCommentFrom.isSelected = false
                
                cell.btnEditCommentFrom.isHidden = false
                cell.btnDeleteCommentFrom.isHidden = false
                
                cell.btnEditCommentTo.isHidden = true
                cell.btnDeleteCommentTo.isHidden = true
            }
            
            if comment?.userId == settings?.userId && comment?.publisherId != comment?.userId {
                cell.btnEditCommentTo.isSelected = false
                cell.btnDeleteCommentTo.isSelected = false
                
                cell.btnEditCommentTo.isHidden = false
                cell.btnDeleteCommentTo.isHidden = false
                
                cell.btnEditCommentFrom.isHidden = true
                cell.btnDeleteCommentFrom.isHidden = true
            }
        }
        
        // Set user info
        cell.lblUserFrom.text = "\(dict.whoShared?.firstName ?? "") \(dict.whoShared?.lastName ?? "")"
        cell.lblUserTo.text = "\(dict.sharedWith?.firstName ?? "") \(dict.sharedWith?.lastName ?? "")"
        
        cell.btnLike.isSelected = dict.didILike
        cell.btnFavourite.isSelected = dict.isFavourite
        cell.lblLikeCount.text = String(dict.likeCounts)
        cell.lblShareWishieCount.text = String(dict.commentCounts)
        
        // Set tags
        cell.lblUserTo.tag = indexPath.row
        cell.lblUserFrom.tag = indexPath.row
        cell.txtCommentFrom.tag = indexPath.row
        cell.txtCommentTo.tag = indexPath.row
        cell.btnShare.tag = indexPath.row
        cell.btnLike.tag = indexPath.row
        cell.btnShareWishie.tag = indexPath.row
        cell.btnFavourite.tag = indexPath.row
        cell.btnEditCommentFrom.tag = indexPath.row
        cell.btnCloseFrom.tag = indexPath.row
        cell.btnDeleteCommentFrom.tag = indexPath.row
        cell.btnEditCommentTo.tag = indexPath.row
        cell.btnCloseTo.tag = indexPath.row
        cell.btnDeleteCommentTo.tag = indexPath.row
        
        cell.lblUserTo.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(lblUserToClicked(_:))))
        cell.lblUserFrom.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(lblUserFromClicked(_:))))
        cell.btnShare.addTarget(self, action: #selector(shareClicked(_:)), for: .touchUpInside)
        cell.btnShareWishie.addTarget(self, action: #selector(shareWishieClicked(_:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(likedClicked(_:)), for: .touchUpInside)
        cell.btnFavourite.addTarget(self, action: #selector(favouriteClicked(_:)), for: .touchUpInside)
        cell.btnCloseFrom.addTarget(self, action: #selector(closeCommentFrom(_:)), for: .touchUpInside)
        cell.btnCloseTo.addTarget(self, action: #selector(closeCommentTo(_:)), for: .touchUpInside)
        cell.btnEditCommentFrom.addTarget(self, action: #selector(editCommentFromClicked(_:)), for: .touchUpInside)
        cell.btnEditCommentTo.addTarget(self, action: #selector(editCommentToClicked(_:)), for: .touchUpInside)
        cell.btnDeleteCommentFrom.addTarget(self, action: #selector(deleteCommentFromClicked(_:)), for: .touchUpInside)
        cell.btnDeleteCommentTo.addTarget(self, action: #selector(deleteCommentToClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
}

// MARK: - API CALL
extension FeedsViewController {
    func fetchFeeds() {
        WSManager.wsCallGetFeeds { (isSuccess, message, response) in
            self.videos = []
            
            if let response = response {
                self.videos = response
                
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func saveToWishie(_ videoId: Int, _ publisherId: Int) {
        let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject,
                                           WSRequestParams.publisherId: publisherId as AnyObject]
        WSManager.wsCallSaveVideo(params) { (isSuccess, message) in
            
        }
    }
    
    func likeVideo(_ videoId: Int) {
        let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject]
        WSManager.wsCallLikeVideo(params) { (isSuccess, message) in
            
        }
    }
    
    func deleteComment(_ commentId: Int) {
        WSManager.wsCallDeleteComment(commentId) { (isSuccess, message) in
            
        }
    }
}
