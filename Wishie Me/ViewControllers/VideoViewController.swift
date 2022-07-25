import UIKit
import AVFoundation

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var videoURL: URL!
    var typeOfWishie = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = typeOfWishie
        
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.darkGrayColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneClicked(_:)))
        rightBarButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        cameraViewControllerDelegate?.fromVideoController()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if let vc = ViewControllerHelper.getViewController(ofType: .VideoShareViewController) as? VideoShareViewController {
            vc.videoURL = videoURL
            vc.typeOfWishie = typeOfWishie
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
