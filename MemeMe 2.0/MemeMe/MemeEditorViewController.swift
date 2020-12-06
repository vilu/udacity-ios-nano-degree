import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    private enum Constants {
        enum Tags: Int {
            case topLabel
            case bottomLabel
            case cameraButton
            case AlbumButton
        }
        
        enum Layout {
            static let font:String = "Impact"
            static let topInset: CGFloat = 40.0
            static let leftInset: CGFloat = 10.0
            static let rightInset: CGFloat = -10.0
            static let bottomInset: CGFloat = -40.0
            static let textStroke: CGFloat = -3.0
            static let fontSize: CGFloat = 45.0
        }
        
        enum Text {
            static let topLabel = "TOP"
            static let bottomLabel = "BOTTOM"
            static let cancel = "Cancel"
            static let album = "Album"
        }
    }
    
    var topTextField: UITextField!
    var bottomTextField: UITextField!
    var imagePickerView: UIImageView!
    var bottomConstraint: NSLayoutConstraint!
    var topToolbar: UIToolbar!
    var bottomToolbar: UIToolbar!
    var shareButton: UIBarButtonItem!
    
    private var originTabBarVisibility: Bool = false
    private var originNavBarVisibility: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar = UIToolbar()
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareWasTapped))
        shareButton.isEnabled = false
        let cancelButton = UIBarButtonItem(title: Constants.Text.cancel, style: .plain, target: self, action: #selector(cancel))
        topToolbar.items = [shareButton, UIBarButtonItem.flexibleSpace() ,cancelButton]
        topToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topToolbar)
    
        imagePickerView = UIImageView()
        imagePickerView.backgroundColor = .black
        imagePickerView.contentMode = .scaleAspectFit
        view.addSubview(imagePickerView)
        imagePickerView.translatesAutoresizingMaskIntoConstraints = false

        topTextField = UITextField()
        topTextField.defaultTextAttributes = memeDefaultTextAttributes()
        topTextField.autocapitalizationType = .allCharacters
        topTextField.adjustsFontSizeToFitWidth = true
        topTextField.textAlignment = .center
        topTextField.translatesAutoresizingMaskIntoConstraints = false
        topTextField.delegate = self
        topTextField.text = Constants.Text.topLabel
        topTextField.tag = Constants.Tags.topLabel.rawValue
        
        bottomTextField = UITextField()
        bottomTextField.defaultTextAttributes = memeDefaultTextAttributes()
        bottomTextField.textAlignment = .center
        bottomTextField.autocapitalizationType = .allCharacters
        bottomTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.translatesAutoresizingMaskIntoConstraints = false
        bottomTextField.delegate = self
        bottomTextField.tag = Constants.Tags.bottomLabel.rawValue
        bottomTextField.text = Constants.Text.bottomLabel
        
        view.addSubview(topTextField)
        view.addSubview(bottomTextField)
        
        bottomToolbar = UIToolbar()
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera,target: self, action: #selector(pickImage))
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        cameraButton.tag = Constants.Tags.cameraButton.rawValue
        let albumButton = UIBarButtonItem(title: Constants.Text.album, style: .plain, target: self, action: #selector(pickImage))
        albumButton.tag = Constants.Tags.AlbumButton.rawValue
        bottomToolbar.items = [
            UIBarButtonItem.flexibleSpace(),
            cameraButton,
            UIBarButtonItem.flexibleSpace(),
            albumButton,
            UIBarButtonItem.flexibleSpace()
        ]
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)
        
        bottomConstraint = bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            topToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // Bottom toolbar constraints
            bottomConstraint,
            bottomToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // Image view constraints
            imagePickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imagePickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imagePickerView.topAnchor.constraint(equalTo: topToolbar.bottomAnchor),
            imagePickerView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            // Top text constraints
            topTextField.leadingAnchor.constraint(equalTo: imagePickerView.leadingAnchor, constant: Constants.Layout.rightInset),
            topTextField.trailingAnchor.constraint(equalTo: imagePickerView.trailingAnchor, constant: Constants.Layout.leftInset),
            topTextField.topAnchor.constraint(equalTo: imagePickerView.topAnchor, constant: Constants.Layout.topInset),
            // Bottom text constraints
            bottomTextField.leadingAnchor.constraint(equalTo: imagePickerView.leadingAnchor, constant: Constants.Layout.leftInset),
            bottomTextField.trailingAnchor.constraint(equalTo: imagePickerView.trailingAnchor, constant: Constants.Layout.rightInset),
            bottomTextField.bottomAnchor.constraint(equalTo: imagePickerView.bottomAnchor, constant: Constants.Layout.bottomInset)
        ])
    }
    
    private func memeDefaultTextAttributes() -> [NSAttributedString.Key : Any] {
        [
            NSAttributedString.Key.font: UIFont(name: Constants.Layout.font, size: Constants.Layout.fontSize) as Any,
            NSAttributedString.Key.foregroundColor:  UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.strokeWidth: Constants.Layout.textStroke,
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        if let navigationController = navigationController {
            originNavBarVisibility = navigationController.isNavigationBarHidden
            navigationController.isNavigationBarHidden = true
        }
        
        if let tabBarController = tabBarController {
            originTabBarVisibility = tabBarController.tabBar.isHidden
            tabBarController.tabBar.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()

        if let navigationController = navigationController {
            navigationController.isNavigationBarHidden = originNavBarVisibility
        }
        
        if let tabBarController = tabBarController {
            tabBarController.tabBar.isHidden = originTabBarVisibility
        }
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            bottomConstraint.constant = -getKeyboardHeight(notification)
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        bottomConstraint.constant = 0
    }
    
    @objc private func pickImage(sender: UIBarButtonItem) {
        let sourceType: UIImagePickerController.SourceType?
        switch sender.tag {
        case Constants.Tags.AlbumButton.rawValue:
            sourceType = .photoLibrary
        case Constants.Tags.cameraButton.rawValue:
            sourceType = .camera
        default:
            sourceType = nil
        }
        
        sourceType.map { sourceType in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    private func toggleShareButton() {
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
    private func focusOnMemeContent(_ enable: Bool) {
        topToolbar.isHidden = enable
        bottomToolbar.isHidden = enable
    }
    
    private func generateMemedImage() -> UIImage {
        focusOnMemeContent(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        focusOnMemeContent(false)
        return memedImage
    }

    @objc private func shareWasTapped() {
        let memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (_, completed, _, _) in
            if completed {
                self.save(memedImage: memedImage)
            }
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    private func save(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text ?? "", originalImage: imagePickerView.image!, memedImage: memedImage, bottomText: bottomTextField.text ?? "")
        
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
    
    @objc private func cancel() {
        topTextField.text = Constants.Text.topLabel
        bottomTextField.text = Constants.Text.bottomLabel
        imagePickerView.image = nil
        toggleShareButton()
        navigationController.map { $0.popViewController(animated: true) }
    }
    
    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

}

// MARK: - UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.tag == Constants.Tags.topLabel.rawValue && textField.text == Constants.Text.topLabel) {
            textField.text = ""
        }
        
        if (textField.tag == Constants.Tags.bottomLabel.rawValue && textField.text == Constants.Text.bottomLabel) {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        toggleShareButton()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Model
struct Meme {
    let topText: String
    let originalImage: UIImage?
    let memedImage: UIImage?
    let bottomText: String
}
