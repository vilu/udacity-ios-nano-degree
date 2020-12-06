import Foundation
import UIKit

final class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        let space:CGFloat = 3.0

        let finalDimension = min(
            (view.frame.size.width - (2 * space)) / 3.0,
            (view.frame.size.height - (2 * space)) / 3.0
        )
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: finalDimension, height: finalDimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (UIApplication.shared.delegate as! AppDelegate).memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let meme = (UIApplication.shared.delegate as! AppDelegate).memes[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath) as! MemeCollectionCell
        
        cell.meme.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        
        let meme = (UIApplication.shared.delegate as! AppDelegate).memes[didSelectItemAt.row]
        
        detailController.meme = meme
        
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @IBAction func didTapNavBarRightButton(_ sender: UIBarButtonItem) {
        let memeEditorViewController = self.storyboard!.instantiateViewController(withIdentifier: "memeEditorViewController") as! MemeEditorViewController
        
        self.navigationController!.pushViewController(memeEditorViewController, animated: true)
    }

}
