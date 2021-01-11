import UIKit

final class LocationTableViewController: UITableViewController {
    
    @IBAction func logoutOnTap(_ sender: Any) {
        AppDependencies.udacityAPI.signOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.dismiss(animated: true)
                case .failure(let error):
                    print("UdacityAPI API Error: \(String(describing: error))")
                    let alert = UIAlertController.defaultAlert(title: "Failed to sign out")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func refreshOnTap(_ sender: Any) {
        updateLocations()
    }
    
    @IBAction func addLocationOnTap(_ sender: Any) {
        guard let storyboard = storyboard, let navigationController = navigationController else {
            return
        }
        
        let addLocationVC = storyboard.instantiateViewController(identifier: Constants.Layout.Identifiers.addLocationViewController)
        navigationController.pushViewController(addLocationVC,
                                                animated: true)
    }
    
    override func viewDidLoad() {
        updateLocations()
    }
    
    private func updateLocations() {
        AppDependencies.parseAPI.fetchLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    AppState.shared.studentInformations = locations
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
        return AppState.shared.studentInformations.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationCell = tableView.dequeueReusableCell(withIdentifier: Constants.Layout.Identifiers.locationCell, for: indexPath) as! LocationCell
        
        let studentLocation = AppState.shared.studentInformations[indexPath.row]
        
        locationCell.userName.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        locationCell.website.text = studentLocation.mediaURL
        
        return locationCell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = AppState.shared.studentInformations[indexPath.row]
        
        attemptOpenWithAlertFallback(url: studentLocation.mediaURL)
    }
}
