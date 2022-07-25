import UIKit

class GenderViewController: UIViewController {

    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnOther: UIButton!
    @IBOutlet weak var imgFemale: UIImageView!
    @IBOutlet weak var imgMale: UIImageView!
    @IBOutlet weak var imgOther: UIImageView!
    
    var rightBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupGender()
    }

    func setupNavigationBar() {
        let leftBarButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backClicked(_:)))
        leftBarButton.tintColor = WishieMeColors.greenColor
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarButton = UIBarButtonItem.init(title: Strings.NEXT, style: .plain, target: self, action: #selector(nextClicked(_:)))
        rightBarButton.tintColor = UIColor.officialApplePlaceholderGray
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_16 ?? UIFont.systemFontSize], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupGender() {
        if UserData.gender != nil {
            if UserData.gender == Strings.FEMALE {
                imgFemale.image = #imageLiteral(resourceName: "ic_selected")
                imgMale.image = #imageLiteral(resourceName: "ic_unselected")
                imgOther.image = #imageLiteral(resourceName: "ic_unselected")
                btnFemale.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
                btnFemale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
            }
            else if UserData.gender == Strings.MALE {
                imgMale.image = #imageLiteral(resourceName: "ic_selected")
                imgFemale.image = #imageLiteral(resourceName: "ic_unselected")
                imgOther.image = #imageLiteral(resourceName: "ic_unselected")
                btnMale.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
                btnMale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
            }
            else if UserData.gender == Strings.OTHER {
                imgOther.image = #imageLiteral(resourceName: "ic_selected")
                imgFemale.image = #imageLiteral(resourceName: "ic_unselected")
                imgMale.image = #imageLiteral(resourceName: "ic_unselected")
                btnOther.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
                btnOther.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
            }
            
            rightBarButton.tintColor = WishieMeColors.greenColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        if !(UserData.gender?.isEmpty ?? true) {
            if let vc = ViewControllerHelper.getViewController(ofType: .UsernameViewController) as? UsernameViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func femaleClicked(_ sender: UIButton) {
        btnFemale.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        btnMale.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        btnOther.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        
        btnFemale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
        btnMale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        btnOther.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        
        imgFemale.image = #imageLiteral(resourceName: "ic_selected")
        imgMale.image = #imageLiteral(resourceName: "ic_unselected")
        imgOther.image = #imageLiteral(resourceName: "ic_unselected")
        
        rightBarButton.tintColor = WishieMeColors.greenColor
        UserData.gender = Strings.FEMALE
    }
    
    @IBAction func maleClicked(_ sender: UIButton) {
        btnMale.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        btnFemale.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        btnOther.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        
        btnMale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
        btnFemale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        btnOther.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        
        imgMale.image = #imageLiteral(resourceName: "ic_selected")
        imgFemale.image = #imageLiteral(resourceName: "ic_unselected")
        imgOther.image = #imageLiteral(resourceName: "ic_unselected")
        
        rightBarButton.tintColor = WishieMeColors.greenColor
        UserData.gender = Strings.MALE
    }
    
    @IBAction func otherClicked(_ sender: UIButton) {
        btnOther.setTitleColor(WishieMeColors.greenColor, for: UIControl.State())
        btnFemale.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        btnMale.setTitleColor(WishieMeColors.darkGrayColor, for: UIControl.State())
        
        btnOther.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_SEMIBOLD_18
        btnFemale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        btnMale.titleLabel?.font = WishieMeFonts.FONT_MONTSERRAT_REGULAR_16
        
        imgOther.image = #imageLiteral(resourceName: "ic_selected")
        imgFemale.image = #imageLiteral(resourceName: "ic_unselected")
        imgMale.image = #imageLiteral(resourceName: "ic_unselected")
        
        rightBarButton.tintColor = WishieMeColors.greenColor
        UserData.gender = Strings.OTHER
    }
}
