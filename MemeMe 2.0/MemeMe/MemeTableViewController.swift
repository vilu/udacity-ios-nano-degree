import Foundation
import UIKit

final class MemeTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (UIApplication.shared.delegate as! AppDelegate).memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meme = (UIApplication.shared.delegate as! AppDelegate).memes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell") as! MemeTableCell
        
        cell.label.text = meme.topText
        cell.meme.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        
            let meme = (UIApplication.shared.delegate as! AppDelegate).memes[indexPath.row]
        
            detailController.meme = meme
        
            self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @IBAction func didTapNavBarRightButton(_ sender: UIBarButtonItem) {
        let memeEditorViewController = self.storyboard!.instantiateViewController(withIdentifier: "memeEditorViewController") as! MemeEditorViewController

        self.navigationController!.pushViewController(memeEditorViewController, animated: true)
    }
}

