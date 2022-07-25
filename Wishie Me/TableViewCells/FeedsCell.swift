import UIKit
import AVFoundation

protocol FeedsCellDelegate {
    func emptyText()
}

var feedsCellDelegate: FeedsCellDelegate?

class FeedsCell: UITableViewCell, ASAutoPlayVideoLayerContainer {

    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var imgUserFrom: UIImageView!
    @IBOutlet weak var imgUserTo: UIImageView!
    @IBOutlet weak var imgTypeOfWishie: UIImageView!
    @IBOutlet weak var imgCommentFrom: UIImageView!
    @IBOutlet weak var imgCommentTo: UIImageView!
    @IBOutlet weak var lblUserFrom: UILabel!
    @IBOutlet weak var lblUserTo: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var viewCommentTo: UIView!
    @IBOutlet weak var viewCommentFrom: UIView!
    @IBOutlet weak var txtCommentFrom: PlaceholderTextView!
    @IBOutlet weak var lblCommentFromTime: UILabel!
    @IBOutlet weak var lblCommentToTime: UILabel!
    @IBOutlet weak var txtCommentTo: PlaceholderTextView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblShareWishieCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnShareWishie: UIButton!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var btnEditCommentTo: UIButton!
    @IBOutlet weak var btnDeleteCommentTo: UIButton!
    @IBOutlet weak var btnCloseTo: UIButton!
    @IBOutlet weak var btnEditCommentFrom: UIButton!
    @IBOutlet weak var btnDeleteCommentFrom: UIButton!
    @IBOutlet weak var btnCloseFrom: UIButton!
    
    var isEmptyText = false
    var videoId: Int?
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedsCellDelegate = self
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        videoImage.layer.addSublayer(videoLayer)
        selectionStyle = .none
        
        txtCommentFrom.delegate = self
        txtCommentTo.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(imageUrl: String?, videoUrl: String?) {
        self.videoImage.imageURL = imageUrl
        self.videoURL = videoUrl
    }
    
    override func prepareForReuse() {
        videoImage.imageURL = nil
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.videoLayer.frame = CGRect(x: 0, y: 0, width: AppConstants.PORTRAIT_SCREEN_WIDTH, height: self.videoImage.frame.height)
        }
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(videoImage.frame, from: videoImage)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
}

// MARK: - CUSTOM DELEGATE
extension FeedsCell: FeedsCellDelegate {
    func emptyText() {
        isEmptyText = true
    }
}

// MARK: - UTEXTVIEW DELEGATE
extension FeedsCell: UITextViewDelegate {    
    func textViewDidBeginEditing(_ textView: UITextView) {
        feedsViewControllerDelegate?.textViewDidBeginEditing(textView)
        
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if isEmptyText {
            isEmptyText = false
            
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Get the new text.
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        // Stop user to enter space as first character
        if range.location == 0 && newText == " " {
            return false
        }
        
        // post comment if done from keyboard is pressed
        if text == "\n" {
            if newText != "\n" {
                postComment(textView)
            }
            return false
        }
        
        // don't allow user to enter more than 100 characters.
        if textView.text.count >= 100 && newText.count >= 100 {
            return false
        }
        
        return true
    }
}

// MARK: - API CALL
extension FeedsCell {
    func postComment(_ textView: UITextView) {
        let params: [String: AnyObject] = [WSRequestParams.videoId: videoId as AnyObject,
                                           WSRequestParams.comment: textView.text as AnyObject]
        WSManager.wsCallPostComment(params) { (isSuccess, message, comment) in
            feedsViewControllerDelegate?.reloadCell(textView, comment)
        }
    }
}
