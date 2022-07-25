import UIKit
import AVFoundation

enum CameraPosition {
    case Front
    case Back
}

protocol CameraViewControllerDelegate {
    func fromVideoController()
    func removeViewFromShare()
    func sendToDraft()
}

var cameraViewControllerDelegate: CameraViewControllerDelegate?

class CameraViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnStartCapture: UIButton!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var effectsView: UIView!
    @IBOutlet weak var imgEffects: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var timerBackView: UIView!
    
    var effects = [UIImage]()
    var timerBarButton = UIBarButtonItem()
    var backgroundBarButton = UIBarButtonItem()
    var timer = Timer()
    var cameraTimer = Timer()
    var counterTimer = Timer()
    var progressViewTimer = Timer()
    var isTimerEnable = false
    var isFromVideoController = false
    var isBackgroundImage = false
    var timeInSeconds = 0.0
    var timeCounter = 0.0
    var typeOfWishie = ""
    
    var captureSession = AVCaptureSession()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var lblCounter: UILabel!
    //var btnStart: UIButton!
    lazy var notifier: NotificationManager = {
        NotificationManager()
    }()
    
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
    
    var currentState: CameraPosition? {
        didSet {
            configCamera(state: currentState ?? CameraPosition.Front)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraViewControllerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        isBackgroundImage = false
        progressView.setProgress(0.0, animated: false)
        
        if !isFromVideoController {
            self.navigationItem.leftBarButtonItems = nil
            chooseWishie()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        if setupSession(.front) {
            setupPreview()
            startSession()
        }
    }
    
    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.darkGrayColor
        
        var wishieType = UIBarButtonItem()
        if typeOfWishie == Strings.WISHIE_BIRTHDAY {
            wishieType = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_birthday"), style: .plain, target: self, action: nil)
        }
        else if typeOfWishie == Strings.WISHIE_APPRECIATION {
            wishieType = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_appreciation"), style: .plain, target: self, action: nil)
        }
        else if typeOfWishie == Strings.WISHIE_THANK_YOU {
            wishieType = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_thankYou"), style: .plain, target: self, action: nil)
        }
        
        self.navigationItem.leftBarButtonItems = [leftBarButton, wishieType]
        
        // Right Bar Buttons
        let cameraFlip = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_camera_flip"), style: .plain, target: self, action: #selector(cameraFlip(_:)))
        timerBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_timer_unselected"), style: .plain, target: self, action: #selector(timerClicked(_:)))
        let sound = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_sounds"), style: .plain, target: self, action: nil)
        backgroundBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_background"), style: .plain, target: self, action: #selector(backgroundClicked(_:)))
        
        self.navigationItem.rightBarButtonItems = [cameraFlip, timerBarButton, sound, backgroundBarButton]
        
        bottomView.isHidden = false
    }
    
    func chooseWishie() {
        Helper.showThreeWishieOptionActionAlert(onVC: self, title: Alert.CHOOSE_WISHIE, titleOne: Strings.WISHIE_BIRTHDAY, actionOne: {
            self.typeOfWishie = Strings.WISHIE_BIRTHDAY
            self.setupNavigationBar()
        }, titleTwo: Strings.WISHIE_APPRECIATION, actionTwo: {
            self.typeOfWishie = Strings.WISHIE_APPRECIATION
            self.setupNavigationBar()
        }, titleThree: Strings.WISHIE_THANK_YOU, actionThree: {
            self.typeOfWishie = Strings.WISHIE_THANK_YOU
            self.setupNavigationBar()
        }, actionCancel: {
            self.tabBarController?.selectedIndex = self.settings?.lastTabIndex ?? 0
        }, styleType: .default)
    }
    
    func hideViews() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        
        //btnStart.isHidden = true
        bottomView.isHidden = true
        effectsView.isHidden = true
        imgEffects.isHidden = true
        isFromVideoController = false
    }
    
    func configCamera(state: CameraPosition) {
        switch state {
        case .Front:
            if setupSession(.front) {
                setupPreview()
                startSession()
            }
        case .Back:
            if setupSession(.back) {
                setupPreview()
                startSession()
            }
        }
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
        
        // Configure timer label
        lblCounter = UILabel()
        lblCounter.font = WishieMeFonts.FONT_MONTSERRAT_MEDIUM_102
        lblCounter.frame = camPreview.bounds
        lblCounter.textAlignment = .center
        lblCounter.textColor = UIColor.black
        lblCounter.isHidden = true
        camPreview.layer.addSublayer(lblCounter.layer)
        
        self.view.layer.addSublayer(bottomView.layer)
    }
    
    @objc func startProgress() {
        progressView.progress += 0.0066
        progressView.setProgress(progressView.progress, animated: true)
        
        if(progressView.progress == 1.0)
        {
            progressViewTimer.invalidate()
        }
    }
    
    func changeTimerTitle(_ sender: UIButton) {
        isTimerEnable = true
        timerStackView.isHidden = true
        timerBackView.isHidden = true
        timerBarButton.image = nil
        timerBarButton.title = sender.titleLabel?.text
        timeInSeconds = Double(sender.titleLabel?.text?.replacingOccurrences(of: " sec", with: "") ?? "0.0") ?? 0.0
        timeCounter = timeInSeconds
    }
    
    @objc func counterTimerFired() {
        self.timeCounter = self.timeCounter - 1
        self.lblCounter.text = String(format: "%.0f", self.timeCounter)
    }
    
    func timerOff() {
        lblCounter.isHidden = true
        isTimerEnable = false
        timerStackView.isHidden = true
        timerBackView.isHidden = true
        timerBarButton.image = #imageLiteral(resourceName: "ic_timer_unselected")
        timerBarButton.title = nil
        timeInSeconds = 0.0
    }
    
    @objc func timerFired() {
        isTimerEnable = false
        timeCounter = 0
        lblCounter.isHidden = true
        counterTimer.invalidate()
        
        startRecording()
    }
    
    @objc func stopCameraRecording() {
        stopRecording()
    }
    
    //MARK:- Setup Camera
    func setupSession(_ position: AVCaptureDevice.Position) -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return false }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else { return false }
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            btnStartCapture.backgroundColor = UIColor.red
            //btnStartCapture.setImage(#imageLiteral(resourceName: "ic_video_stop"), for: UIControl.State())
            
            let connection = movieOutput.connection(with: AVMediaType.video)

            if ((connection?.isVideoOrientationSupported) != nil) {
                connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            }

            if ((connection?.isVideoStabilizationSupported) != nil) {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }

            cameraTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(stopCameraRecording), userInfo: nil, repeats: false)
            progressViewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(startProgress), userInfo: nil, repeats: true)

            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
        else {
            btnStartCapture.backgroundColor = WishieMeColors.greenColor
            //btnStart.setImage(nil, for: UIControl.State())
            
            // Set progress view to 100 if user stops recording
            progressView.setProgress(1.0, animated: true)
            stopRecording()
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.hideViews()
        ShareVideo.clear()
        
        self.tabBarController?.selectedIndex = settings?.lastTabIndex ?? 0
    }
    
    @IBAction func cameraFlip(_ sender: UIBarButtonItem) {
        captureSession = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        
        if currentState == .Back {
            currentState = .Front
        }
        else {
            currentState = .Back
        }
    }
    
    @IBAction func backgroundClicked(_ sender: UIBarButtonItem) {
        if !isBackgroundImage {
            choosePhotoFromExistingImages()
        }
        else {
            captureSession = AVCaptureSession()
            movieOutput = AVCaptureMovieFileOutput()
            isBackgroundImage = false
            
            imgEffects.image = nil
            imgEffects.isHidden = true
            
            backgroundBarButton.image = #imageLiteral(resourceName: "ic_background")
        }
    }
    
    @IBAction func timerClicked(_ sender: UIBarButtonItem) {
        if timerStackView.isHidden {
            timerStackView.isHidden = false
            timerBackView.isHidden = false
            
            sender.image = #imageLiteral(resourceName: "ic_timer_selected")
        }
        else {
            timerStackView.isHidden = true
            timerBackView.isHidden = true
            
            sender.image = #imageLiteral(resourceName: "ic_timer_unselected")
        }
    }
    
    @IBAction func timerOffClicked(_ sender: UIButton) {
        timerOff()
    }
    
    @IBAction func threeSecondsClicked(_ sender: UIButton) {
        changeTimerTitle(sender)
    }
    
    @IBAction func fiveSecondsClicked(_ sender: UIButton) {
        changeTimerTitle(sender)
    }
    
    @IBAction func tenSecondsClicked(_ sender: UIButton) {
        changeTimerTitle(sender)
    }
    
    @IBAction func templatesClicked(_ sender: UIButton) {
        if effectsView.isHidden {
            effectsView.isHidden = false
        }
        else {
            effectsView.isHidden = true
        }
        
        effects = [UIImage(named: "img_template_0")!, UIImage(named: "img_template_1")!, UIImage(named: "img_template_2")!, UIImage(named: "img_template_3")!, UIImage(named: "img_template_4")!, UIImage(named: "img_template_5")!, UIImage(named: "img_template_6")!, UIImage(named: "img_template_7")!, UIImage(named: "img_template_8")!, UIImage(named: "img_template_9")!, UIImage(named: "img_template_10")!]
        collectionView.reloadData()
    }
    
    @IBAction func effectsClicked(_ sender: UIButton) {
        if effectsView.isHidden {
            effectsView.isHidden = false
        }
        else {
            effectsView.isHidden = true
        }
    }
    
    @IBAction func startCapture(_ sender: UIButton) {
        if isTimerEnable {
            lblCounter.isHidden = false
            lblCounter.text = String(format: "%.0f", timeCounter)
            
            timer = Timer.scheduledTimer(timeInterval: timeInSeconds, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
            counterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(counterTimerFired), userInfo: nil, repeats: true)
        }
        else {
            startRecording()
        }
    }
}

// MARK: - UIIMAGEPICKERCONTROLLER DELEGATE
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func choosePhotoFromExistingImages() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        DispatchQueue.main.async {
            self.backgroundBarButton.image = #imageLiteral(resourceName: "ic_background_selected")
            self.isBackgroundImage = true
            self.captureSession = AVCaptureSession()
            self.movieOutput = AVCaptureMovieFileOutput()
            
            self.imgEffects.image = editedImage
            self.imgEffects.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CUSTOM DELEGATE
extension CameraViewController: CameraViewControllerDelegate {
    func fromVideoController() {
        isFromVideoController = true
    }
    
    func removeViewFromShare() {
        self.hideViews()
        ShareVideo.clear()
        
        self.tabBarController?.selectedIndex = settings?.lastTabIndex ?? 0
    }
    
    func sendToDraft() {
        self.hideViews()
        ShareVideo.clear()
        
        self.tabBarController?.selectedIndex = settings?.lastTabIndex ?? 0
        
        notifier.send(NOTIFICATION_SEND_TO_DRAFT)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        }
        else {
            let videoRecorded = outputURL! as URL
            if let vc = ViewControllerHelper.getViewController(ofType: .VideoViewController) as? VideoViewController {
                vc.videoURL = videoRecorded
                vc.typeOfWishie = typeOfWishie
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - COLLECTIONVIEW METHODS
extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.EffectsCell, for: indexPath) as! EffectsCell
        
        cell.imgPreview.image = effects[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        captureSession = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        
        backgroundBarButton.image = #imageLiteral(resourceName: "ic_background")
        isBackgroundImage = false
        
        if indexPath.row == 0 {
            self.effectsView.isHidden = true
            self.imgEffects.image = nil
            self.imgEffects.isHidden = true
        }
        else {
            self.effectsView.isHidden = true
            self.imgEffects.image = self.effects[indexPath.row]
            self.imgEffects.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: 80.0)
    }
}
