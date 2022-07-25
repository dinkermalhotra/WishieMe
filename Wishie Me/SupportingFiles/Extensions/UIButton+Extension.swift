import UIKit

class WishieMeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
    }
    
    override func draw(_ rect: CGRect) {
        // Setup the border.
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = WishieMeColors.greenColor.cgColor
        layer.backgroundColor = WishieMeColors.greenColor.cgColor
        setTitleColor(UIColor.white, for: UIControl.State())
        layer.borderWidth = 0.5
    }
}

class CustomSwitch: UISwitch
{
    override func awakeFromNib () {
        super.awakeFromNib ()
        
        let dispSize: CGSize = CGSize (width: 40, height: 24)
        let scaleX: CGFloat = dispSize.width/self.bounds.size.width
        let scaleY: CGFloat = dispSize.height/self.bounds.size.height
        self.transform = CGAffineTransform (scaleX: scaleX, y: scaleY)
    }
}
