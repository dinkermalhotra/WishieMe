import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnPhoneNumber: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgProfile.layer.cornerRadius = 37
        self.imgProfile.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
