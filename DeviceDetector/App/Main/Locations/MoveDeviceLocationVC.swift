//
//  MoveDeviceLocationVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/25/24.
//

import UIKit

class MoveDeviceLocationVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    private var deviceId: String
    var locations: [String] = SessionData.user?.locations ?? [] // Array of strings
    private let tableView = UITableView()
    
    private let noLocationsLabel: UILabel = {
        let label = UILabel()
        label.text = """
No Locations

Go to the locations tab
to create a location
"""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Initializer
    init(deviceId: String) {
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let index = locations.firstIndex(of: "All") {
            locations.remove(at: index)
        }
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Move Device Location"

        if locations.isEmpty {
            noLocationsLabel.isHidden = false
        }
        
        view.addSubview(noLocationsLabel)
        NSLayoutConstraint.activate([
            noLocationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noLocationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // Setup TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        // Clear cell content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        let location = locations[indexPath.row]

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
        label.text = location
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
        let selectedLocation = locations[indexPath.row]
        updateDeviceField(deviceId: deviceId, location: selectedLocation)
    }
}
