import UIKit
import AVFoundation
import SDWebImage

class VideoShareViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var lblCharactersLeft: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var btnSend: UIButton!
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var isSetuped = false
    var isFromSavedWishie = false
    var thumbnail: String?
    var shareVideoUrl: URL?
    
    var videoURL: URL!
    var typeOfWishie = ""
    var videoId: Int?
    var isShare = false
    var isShareVia = false
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        if isFromSavedWishie {
            let block: SDExternalCompletionBlock? = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) -> Void in
                //print(image)
                if (image == nil) {
                    return
                }
            }

            if let url = URL(string: thumbnail ?? "") {
                self.imgThumbnail.sd_setImage(with: url, completed: block)
            }
        }
        else {
            self.getThumbnailImageFromVideoUrl(url: videoURL) { (thumbImage) in
                self.imgThumbnail.image = thumbImage
                self.imageData = thumbImage?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !isSetuped {
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = videoView.bounds
            avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoView.layer.insertSublayer(avPlayerLayer, at: 0)
            
            view.layoutIfNeeded()
            
            let playerItem = AVPlayerItem(url: videoURL as URL)
            avPlayer.replaceCurrentItem(with: playerItem)
            
            isSetuped = true
        }
    }

    func setupNavigationBar() {
        self.navigationItem.title = typeOfWishie
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.darkGrayColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        if ShareVideo.name != nil && ShareVideo.id != nil {
            btnSend.setTitle("Send to \(ShareVideo.name ?? "")", for: UIControl.State())
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    func uploadVideo() {
        do {
            let data = try Data(contentsOf: videoURL)
            
            Helper.showLoader(onVC: self)
            self.uploadVideo(data)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func shareVia() {
        if let shareVideo = shareVideoUrl {
            let items: [Any] = [shareVideo]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    cameraViewControllerDelegate?.fromVideoController()
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    DispatchQueue.main.async {
                        cameraViewControllerDelegate?.removeViewFromShare()
                    }
                }
            }
            self.present(ac, animated: true)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        if videoId == nil {
            self.isShare = true
            self.isShareVia = false
            
            self.uploadVideo()
        }
        else {
            Helper.showLoader(onVC: self)
            self.shareVideo()
        }
    }
    
    @IBAction func saveToDraftsClicked(_ sender: UIButton) {
        if isFromSavedWishie {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.isShare = false
            self.isShareVia = false
            
            self.uploadVideo()
        }
    }
    
    @IBAction func shareViaClicked(_ sender: UIButton) {
        if shareVideoUrl?.absoluteString.contains("https://") ?? false {
            shareVia()
        }
        else {
            self.isShare = false
            self.isShareVia = true
            
            self.uploadVideo()
        }
    }
    
    @IBAction func playClicked(_ sender: UIButton) {
        if sender.isSelected {
            avPlayer.pause()
            sender.isSelected = false
        }
        else {
            avPlayer.play()
            sender.isSelected = true
        }
    }
}

// MARK: - UTEXTVIEW DELEGATE
extension VideoShareViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Get the new text.
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if textView.text.count >= 100 && newText.count >= 100 {
            return false
        }
        
        lblCharactersLeft.text = "\(100 - newText.count) characters left"
        
        return true
    }
}

// MARK: - API CALL
extension VideoShareViewController {
    func uploadVideo(_ data: Data) {
        WSManager.wsCallUploadVideo(data, Helper.convertBase64Image(self.imageData), typeOfWishie) { (isSuccess, response, videoId, message) in
            if isSuccess {
                self.videoId = videoId
                self.shareVideoUrl = URL.init(string: "https://wish-me.tk/api/video/video/\(response)")
                
                if !self.txtComments.text.isEmpty {
                    self.postComment()
                }
                
                if self.isShare {
                    self.shareVideo()
                }
                else if self.isShareVia {
                    Helper.hideLoader(onVC: self)
                    self.shareVia()
                }
                else {
                    Helper.hideLoader(onVC: self)
                    
                    cameraViewControllerDelegate?.fromVideoController()
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    DispatchQueue.main.async {
                        cameraViewControllerDelegate?.sendToDraft()
                    }
                }
            }
            else {
                Helper.hideLoader(onVC: self)
            }
        }
    }
    
    func shareVideo() {
        if ShareVideo.id == nil {
            Helper.hideLoader(onVC: self)
            if let vc = ViewControllerHelper.getViewController(ofType: .ShareWithFriendsViewController) as? ShareWithFriendsViewController {
                vc.videoId = self.videoId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject,
                                               WSRequestParams.shareWith: ShareVideo.id as AnyObject]
            WSManager.wsCallShareVideo(params) { (isSuccess, message) in
                Helper.hideLoader(onVC: self)
                
                if isSuccess {
                    userProfileViewControllerDelegate?.refreshData()
                    cameraViewControllerDelegate?.fromVideoController()
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    DispatchQueue.main.async {
                        cameraViewControllerDelegate?.removeViewFromShare()
                    }
                }
                else {
                    Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: message)
                }
            }
        }
    }
    
    func postComment() {
        let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject,
                                           WSRequestParams.comment: txtComments.text as AnyObject]
        WSManager.wsCallPostComment(params) { (isSuccess, message, comment)  in
            feedsViewControllerDelegate?.reloadData()
        }
    }
}
