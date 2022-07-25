import UIKit

class WishieMeView: UIView {
    
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
        tintColor = UIColor.black
        layer.borderWidth = 0.5
    }
}

// MARK: - UIVIEW EXTENSION
extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        } set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        } set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        } set {
            layer.shadowOffset = newValue
        }
    }
    
    func takeScreenshot(size: CGSize) -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            if let image = image
            {
                return image
            }
        }
        
        return UIImage()
    }
    
    func image(_ view: UIView) -> UIImage
    {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image
        {
            (rendererContext) in

            view.layer.render(in: rendererContext.cgContext)
        }
    }
}
