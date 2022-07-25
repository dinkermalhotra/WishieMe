import UIKit
import AVFoundation

enum Tones: String {
    case happy_birthday = "Happy Birthday"
    case happy_birthday_to_yo = "Happy Birthday to You"
}

class TonesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedValue = ""
    var player: AVAudioPlayer?
    var tones = [Tones.happy_birthday, Tones.happy_birthday_to_yo]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Reminder Tone"
        self.navigationController?.navigationBar.tintColor = WishieMeColors.greenColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        addReminderViewControllerDelegate?.selectedTone(selectedValue)
    }
}

// MARK: - UITABLEVIEW METHODS
extension TonesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIds.TonesCell, for: indexPath)
        
        cell.textLabel?.text = tones[indexPath.row].rawValue
        if selectedValue == "\(tones[indexPath.row].self)" {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedValue = "\(tones[indexPath.row].self)"
        guard let path = Bundle.main.path(forResource: selectedValue, ofType: Strings.TONE_EXTENSION) else { return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print(error.localizedDescription)
        }
        
        self.tableView.reloadData()
    }
}
