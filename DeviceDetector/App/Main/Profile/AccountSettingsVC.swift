//
//  AccountSettings.swift
//  DeviceDetector
//
//  Created by Bobby on 11/24/24.
//
import UIKit

class AccountSettingsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // Explicit section order
    private let sections: [String] = ["Notifications", "Account"]
    private let settings: [String: [String]] = [
        "Notifications": ["Text", "Email", "Push"],
        "Account": ["Delete Account", "Sign Out"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Account Settings"
        view.backgroundColor = .systemBackground
        
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = sections[section]
        return settings[sectionKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let sectionKey = sections[indexPath.section]
        let option = settings[sectionKey]?[indexPath.row]
        cell.textLabel?.text = option
        
        if sectionKey == "Notifications" {
            // Add UISwitch for Notifications
            let switchControl = UISwitch()
            
            // Read directly from the SessionData.user
            switch option {
            case "Text":
                switchControl.isOn = SessionData.user?.textNotifications ?? false
            case "Email":
                switchControl.isOn = SessionData.user?.emailNotifications ?? false
            case "Push":
                switchControl.isOn = SessionData.user?.pushNotifications ?? false
            default:
                break
            }
            
            switchControl.tag = indexPath.row // Identify switch by row
            switchControl.addTarget(self, action: #selector(notificationSwitchToggled(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        } else {
            // No switch for Account settings
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionKey = sections[indexPath.section]
        let selectedOption = settings[sectionKey]?[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch selectedOption {
        case "Delete Account":
            handleDeleteAccount()
        case "Sign Out":
            signOut()
        default:
            break
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleDeleteAccount() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to delete your account? This action cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        present(alert, animated: true)
    }
    
    @objc private func notificationSwitchToggled(_ sender: UISwitch) {
        let sectionKey = "Notifications"
        let option = settings[sectionKey]?[sender.tag]
        
        guard let option = option else { return }
        
        // Call the appropriate backend function
        switch option {
        case "Text":
            let parameters: [String: Any] = ["textNotifications": sender.isOn]
            makeAPICall(
                path: "/users/text-notifications",
                method: .PUT,
                parameters: parameters,
                responseType: BasicRes.self
            ) { result in
                switch result {
                case .success(let data):
                    if let error = data.error {
                        sender.isOn = !sender.isOn
                        self.showAlert(message: "There was an error, please try again.")
                        return
                    }
                    SessionData.user.textNotifications = sender.isOn
                case .failure(let error):
                    sender.isOn = !sender.isOn
                    print("Error: \(error.localizedDescription)")
                    self.showAlert(message: "There was an error, please try again.")
                }
            }
            
        case "Email":
            let parameters: [String: Any] = ["emailNotifications": sender.isOn]
            self.makeAPICall(
                path: "/users/email-notifications",
                method: .PUT,
                parameters: parameters,
                responseType: BasicRes.self
            ) { result in
                switch result {
                case .success(let data):
                    if let error = data.error {
                        sender.isOn = !sender.isOn
                        self.showAlert(message: "There was an error, please try again.")
                        return
                    }
                    SessionData.user.emailNotifications = sender.isOn
                case .failure(let error):
                    sender.isOn = !sender.isOn
                    print("Error: \(error.localizedDescription)")
                    self.showAlert(message: "There was an error, please try again.")
                }
            }
        case "Push":
            let parameters: [String: Any] = ["pushNotifications": sender.isOn]
            makeAPICall(
                path: "/users/push-notifications",
                method: .PUT,
                parameters: parameters,
                responseType: BasicRes.self
            ) { result in
                switch result {
                case .success(let data):
                    if let error = data.error {
                        sender.isOn = !sender.isOn
                        self.showAlert(message: "There was an error, please try again.")
                        return
                    }
                    SessionData.user.pushNotifications = sender.isOn
                case .failure(let error):
                    sender.isOn = !sender.isOn
                    print("Error: \(error.localizedDescription)")
                    self.showAlert(message: "There was an error, please try again.")
                }
            }
        default:
            print("Unknown notification option: \(option)")
        }
    }
}
