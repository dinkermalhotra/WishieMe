import Foundation
import UIKit

extension NSMutableAttributedString {
    func setAttributedText(_ string: String, _ startLoc: Int, _ count: Int) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init(string: string)
        attributedString.addAttribute(NSAttributedString.Key.font, value: WishieMeFonts.FONT_MONTSERRAT_MEDIUM_14 ?? UIFont.systemFont(ofSize: 14), range: NSRange.init(location: startLoc, length: count))
        return attributedString
    }
}

extension UISwipeActionsConfiguration {
    public static func makeTitledImage(image: UIImage?, title: String, textColor: UIColor = .white, font: UIFont = .systemFont(ofSize: 16)) -> UIImage? {
        let size: CGSize = .init(width: 76, height: 76)
        
        /// Create attributed string attachment with image
        let attachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            attachment.image = image?.withTintColor(UIColor.white)
        }
        else {
            attachment.image = image
        }
        let imageString = NSAttributedString(attachment: attachment)
        
        /// Create attributed string with title
        let text = NSAttributedString(string: "\n\(title)", attributes: [.foregroundColor: textColor, .font: font])
        
        /// Merge two attributed strings
        let mergedText = NSMutableAttributedString()
        mergedText.append(imageString)
        mergedText.append(text)
        
        /// Create label and append that merged attributed string
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = mergedText
        
        /// Create image from that label
        let renderer = UIGraphicsImageRenderer(bounds: label.bounds)
        let image = renderer.image { rendererContext in
            label.layer.render(in: rendererContext.cgContext)
        }
        
        /// Convert it to UIImage and return
        if let cgImage = image.cgImage {
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }
        
        return nil
    }
}
