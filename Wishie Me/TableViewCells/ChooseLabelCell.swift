import UIKit

class ChooseLabelCell: UITableViewCell {

    @IBOutlet weak var imgLabel: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgSelection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
