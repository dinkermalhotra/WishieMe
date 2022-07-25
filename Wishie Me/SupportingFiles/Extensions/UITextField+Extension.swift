import UIKit

class WishieMeTextField: UITextField {
    
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
        layer.borderColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1.0).cgColor
        layer.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0).cgColor
        textColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1.0)
        tintColor = UIColor.black
        layer.borderWidth = 0.5
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // Add some padding.
        return bounds.insetBy(dx: 12, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // Add some padding.
        return bounds.insetBy(dx: 12, dy: 0)
    }
}
