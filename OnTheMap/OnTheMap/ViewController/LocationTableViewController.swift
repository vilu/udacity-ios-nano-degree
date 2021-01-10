import UIKit

final class LocationTableViewController: UITableViewController {
    
    private var studentLocations = [StudentInformation]()
    
    @IBAction func logoutOnTap(_ sender: Any) {
        guard
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let storyboard = storyboard
        else {
            return
        }
        
        AppDependencies.udacityAPI.signOut { _ in
            DispatchQueue.main.async {
                let vc = storyboard.instantiateViewController(identifier: Constants.Layout.Identifiers.signInViewController)
                
                sceneDelegate.window?.rootViewController = vc
            }
        }
    }
    
    @IBAction func refreshOnTap(_ sender: Any) {
        updateLocations()
    }
    
    @IBAction func addLocationOnTap(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        updateLocations()
    }
    
    private func updateLocations() {
        AppDependencies.parseAPI.fetchLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self.studentLocations = locations
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Parse API Error: \(String(describing: error))")
                    let alert = UIAlertController.defaultAlert(
                        title: "Failed to retrieve student locations",
                        message: "Please retry in the upper right corner",
                        actionTitle: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationCell = tableView.dequeueReusableCell(withIdentifier: Constants.Layout.Identifiers.locationCell, for: indexPath) as! LocationCell
        
        let studentLocation = studentLocations[indexPath.row]
        
        locationCell.userName.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        locationCell.website.text = studentLocation.mediaURL
        
        return locationCell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentLocations[indexPath.row]
        
        attemptOpenWithAlertFallback(url: studentLocation.mediaURL)
    }
}
