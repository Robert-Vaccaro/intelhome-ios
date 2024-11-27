//
//  DevicesVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//
import UIKit

class DevicesVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick A Location"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let noDevicesLabel: UILabel = {
        let label = UILabel()
        label.text = """
No Devices Found

Press the camera button
to scan for devices
"""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tabScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let tabStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let devicesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var devices: [Devices] = [] {
        didSet {
            updateUIForDevices()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        devicesTableView.dataSource = self
        devicesTableView.delegate = self
        devicesTableView.register(DeviceCell.self, forCellReuseIdentifier: "DeviceCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.setupTabs()
        }
    }
    
    // MARK: - Setup Tabs
    private func setupTabs() {
        // Clear all existing tabs
        for view in tabStackView.arrangedSubviews {
            tabStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        if let locations = SessionData.user.locations, !locations.contains("All") {
            SessionData.user.locations?.insert("All", at: 0)
        }
        
        // Add new tabs
        let tabNames = SessionData.user?.locations ?? []
        for tabName in tabNames {
            let tabLabel = PaddedLabel()
            tabLabel.text = tabName
            tabLabel.font = UIFont.boldSystemFont(ofSize: 16)
            tabLabel.textColor = .white
            tabLabel.textAlignment = .center
            tabLabel.layer.borderColor = primaryColor.cgColor
            tabLabel.layer.borderWidth = 2
            tabLabel.layer.cornerRadius = 10
            tabLabel.clipsToBounds = true
            tabLabel.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Add padding
            
            tabLabel.isUserInteractionEnabled = true
            
            // Check if the current tab matches the current location
            if SessionData.currectLocation == tabName {
                tabLabel.backgroundColor = primaryColor
                tabLabel.textColor = .white
            } else {
                tabLabel.backgroundColor = .clear
                tabLabel.textColor = .white
            }
            
            // Add tap gesture for each tab
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            tabLabel.addGestureRecognizer(tapGesture)
            
            tabStackView.addArrangedSubview(tabLabel)
        }
        
        // Automatically fetch devices for the current location, if available
        if !SessionData.currectLocation.isEmpty {
            fetchDevices(location: SessionData.currectLocation)
        } else if let firstTab = tabStackView.arrangedSubviews.first as? UILabel {
            // Default to the first tab if no current location is set
            tabTapped(UITapGestureRecognizer(target: firstTab, action: nil))
        }
    }
    
    
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Devices"
        let detectButton = UIBarButtonItem(
            image: UIImage(systemName: "camera.viewfinder"),
            style: .plain,
            target: self,
            action: #selector(goToDeviceDetectionVC)
        )
        detectButton.tintColor = primaryColor
        navigationItem.rightBarButtonItem = detectButton
        // Add elements to view
        view.addSubview(titleLabel)
        view.addSubview(tabScrollView)
        tabScrollView.addSubview(tabStackView)
        view.addSubview(devicesTableView)
        view.addSubview(noDevicesLabel)
        
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Scroll View
            tabScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tabScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabScrollView.heightAnchor.constraint(equalToConstant: 40),
            
            // Stack View inside Scroll View
            tabStackView.topAnchor.constraint(equalTo: tabScrollView.topAnchor),
            tabStackView.bottomAnchor.constraint(equalTo: tabScrollView.bottomAnchor),
            tabStackView.leadingAnchor.constraint(equalTo: tabScrollView.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: tabScrollView.trailingAnchor),
            
            // Devices Table View
            devicesTableView.topAnchor.constraint(equalTo: tabScrollView.bottomAnchor, constant: 16),
            devicesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            devicesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            devicesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noDevicesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDevicesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    private func updateUIForDevices() {
        if devices.isEmpty {
            noDevicesLabel.isHidden = false
            devicesTableView.isHidden = true
        } else {
            noDevicesLabel.isHidden = true
            devicesTableView.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let tabLabel = sender.view as? UILabel else { return }
        print("Selected tab: \(tabLabel.text ?? "")")
        
        // Change the tab's text color to orange
        tabStackView.arrangedSubviews.forEach { subview in
            if let label = subview as? UILabel {
                label.textColor = .white
                label.backgroundColor = .clear
            }
        }
        tabLabel.textColor = .white
        tabLabel.backgroundColor = primaryColor
        
        // Fetch devices based on the selected location
        if let location = tabLabel.text {
            SessionData.currectLocation = location
            fetchDevices(location: location)
        }
    }
    
    @objc private func goToDeviceDetectionVC() {
        self.activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.navigationController?.pushViewController(DeviceDetectionVC(), animated: true)
        })
    }
    
    // MARK: - Fetch Devices
    private func fetchDevices(location: String = SessionData.currectLocation) {
        let parameters: [String: Any] = ["filter": location]
        
        makeAPICall(
            path: "/devices",
            method: .GET,
            parameters: parameters,
            responseType: [Devices].self
        ) { result in
            switch result {
            case .success(let fetchedDevices):
                DispatchQueue.main.async {
                    self.devices = fetchedDevices
                    SessionData.deviceCount = fetchedDevices.count
                    self.devicesTableView.reloadData()
                    if self.devices.isEmpty {
                        self.noDevicesLabel.isHidden = false
                    } else {
                        self.noDevicesLabel.isHidden = true
                    }
                }
            case .failure(let error):
                print("Failed to fetch devices: \(error.localizedDescription)")
                self.showAlert(message: "There was an error, please try again.")
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as? DeviceCell else {
            return UITableViewCell()
        }
        let device = devices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceId = devices[indexPath.row]
        navigationController?.pushViewController(SpecificDeviceVC(deviceId: deviceId.id), animated: true)
    }
}
