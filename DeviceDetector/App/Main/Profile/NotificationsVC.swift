//
//  NotificationsVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/25/24.
//
import UIKit

class NotificationsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var notifications: [AppNotification] = SessionData.notifications ?? [] {
        didSet {
            updateUIForNotifications()
        }
    }
    
    private let noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No notifications found"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        title = "Notifications"
        
        // Clear All button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllNotifications)
        )
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // TableView setup
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        view.addSubview(noNotificationsLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noNotificationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noNotificationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func updateUIForNotifications() {
        if notifications.isEmpty {
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noNotificationsLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    // MARK: - Clear All Notifications
    @objc private func clearAllNotifications() {
        let parameters: [String: Any] = ["": ""]
        
        makeAPICall(
            path: "/notifications/all",
            method: .DELETE,
            parameters: parameters,
            responseType: BasicRes.self
        ) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.notifications.removeAll()
                    SessionData.notifications = self.notifications
                    self.tableView.reloadData()
                    self.updateUIForNotifications()
                }
            case .failure(let error):
                print("Failed to fetch devices: \(error.localizedDescription)")
                self.showAlert(message: "There was an error, please try again.")
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        
        // Clear cell content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        let notification = notifications[indexPath.row]
        
        // Create container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = .black
        containerView.layer.borderColor = primaryColor.cgColor
        containerView.layer.borderWidth = 1
        cell.contentView.addSubview(containerView)
        
        // Add label inside container view
        let label = UILabel()
        label.text = notification.message
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        // Constraints for container view
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            
            // Label constraints
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let deviceId = notification.deviceId else {
            showAlert(message: "Device not found for this notification.")
            return
        }
        navigationController?.pushViewController(SpecificDeviceVC(deviceId: deviceId), animated: true)
    }
    
    // MARK: - Swipe to Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let parameters: [String: Any] = ["id": notifications[indexPath.row].id]
            
            makeAPICall(
                path: "/notifications",
                method: .DELETE,
                parameters: parameters,
                responseType: BasicRes.self
            ) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.notifications.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        SessionData.notifications = self.notifications
                        self.updateUIForNotifications()
                        completionHandler(true)
                    }
                case .failure(let error):
                    print("Failed to fetch devices: \(error.localizedDescription)")
                    self.showAlert(message: "There was an error, please try again.")
                }
            }

        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
