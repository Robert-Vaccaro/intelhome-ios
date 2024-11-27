//
//  SpecificDeviceVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/25/24.
//

import UIKit

class SpecificDeviceVC: BaseVC {

    // MARK: - Properties
    private var deviceId: String!
    private var device: Device?

    private let noDeviceLabel: UILabel = {
        let label = UILabel()
        label.text = """
No device information found

Please go back and try again
"""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
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
        
//        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let deviceId = deviceId {
            getDeviceInfo(name: deviceId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.device = data.device
                        self.setupUI()
                    case .failure(let error):
                        print("Failed to fetch device: \(error.localizedDescription)")
                        self.showNoDeviceMessage()
                    }
                }
            }
        } else {
            showNoDeviceMessage()
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Clear the view for dynamic updates
        view.subviews.forEach { $0.removeFromSuperview() }

        guard let device = device else {
            showNoDeviceMessage()
            return
        }

        if device.needsUpdate {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Update",
                style: .plain,
                target: self,
                action: #selector(updateDevice)
            )
        }

        // Create a scroll view and content view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Create views for device properties
        let nameView = createPropertyView(title: "Device Name", value: device.name)
        let typeView = createPropertyView(title: "Device Type", value: device.type)
        let locationView = createPropertyView(title: "Location", value: device.location)
        let capabilitiesView = createListView(title: "Capabilities", values: device.capabilities)
        let specificationsView = createListView(
            title: "Specifications",
            values: device.specifications.components(separatedBy: ", ")
        )
        let detectedAtView = createPropertyView(title: "Detected At", value: formatTimestamp(device.detectedAt))
        let needsUpdateView = createPropertyView(title: "Needs Update", value: device.needsUpdate ? "Yes" : "No")

        let moveButton = UIButton(type: .system)
        moveButton.setTitle("Move Device Location", for: .normal)
        moveButton.setTitleColor(.white, for: .normal)
        moveButton.backgroundColor = primaryColor
        moveButton.layer.cornerRadius = 10
        moveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        moveButton.addTarget(self, action: #selector(moveDeviceLocation), for: .touchUpInside)
        moveButton.translatesAutoresizingMaskIntoConstraints = false

        
        // Create a delete button
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Device", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 10
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        deleteButton.addTarget(self, action: #selector(deleteDevice), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        // Stack the views vertically
        let stackView = UIStackView(arrangedSubviews: [
            nameView,
            typeView,
            locationView,
            capabilitiesView,
            specificationsView,
            detectedAtView,
            needsUpdateView,
            moveButton,
            deleteButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),

            moveButton.heightAnchor.constraint(equalToConstant: 50),
            moveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            moveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }



    private func createPropertyView(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = primaryColor.cgColor
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = primaryColor.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),

            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        return containerView
    }

    private func createListView(title: String, values: [String]) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = primaryColor.cgColor
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.attributedText = formatBulletPoints(values)
        valueLabel.numberOfLines = 0
        valueLabel.textColor = .label
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),

            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        return containerView
    }

    // Helper to format an array of strings into bullet points
    private func formatBulletPoints(_ items: [String]) -> NSAttributedString {
        let bullet = "⚙️"
        let bulletPoints = NSMutableAttributedString()

        for item in items {
            let bulletPoint = "\(bullet) \(item.trimmingPrefix(" "))\n"
            let attributedString = NSAttributedString(
                string: bulletPoint,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
            )
            bulletPoints.append(attributedString)
        }

        return bulletPoints
    }

    // Helper to format timestamps
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func showNoDeviceMessage() {
        // Clear existing subviews for consistent state
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(noDeviceLabel)

        NSLayoutConstraint.activate([
            noDeviceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDeviceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        noDeviceLabel.isHidden = false
    }

    // MARK: - API Call
    private func getDeviceInfo(
        name: String,
        completion: @escaping (Result<CreatedDeviceResponse, Error>) -> Void
    ) {
        guard let deviceId = deviceId else {
            showAlert(message: "Could not find device.")
            return
        }
        let path = "/devices/\(deviceId)"

        makeAPICall(
            path: path,
            method: .GET,
            parameters: nil,
            responseType: Device.self
        ) { result in
            switch result {
            case .success(let device):
                self.device = device
                self.setupUI()
            case .failure(let error):
                print("Failed to fetch device: \(error.localizedDescription)")
                self.showAlert(message: "There was an error getting this specific device, please try again.")
            }
        }
    }
    
    @objc func updateDevice() {
        guard let deviceId = deviceId else {
            showAlert(message: "Device information is missing.")
            return
        }
        updateDeviceField(deviceId: deviceId, needsUpdate: false)
    }

    @objc func moveDeviceLocation() {
        guard let deviceId = deviceId else {
            showAlert(message: "Device information is missing.")
            return
        }
        navigationController?.pushViewController(MoveDeviceLocationVC(deviceId: deviceId), animated: true)
    }
    
    
    @objc func deleteDevice() {
        guard let deviceId = deviceId else {
            showAlert(message: "Device information is missing.")
            return
        }

        let parameters: [String: Any] = [
            "deviceId": deviceId,
        ]

        makeAPICall(
            path: "/devices",
            method: .DELETE,
            parameters: parameters,
            responseType: BasicRes.self
        ) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.goToVC(vc: MainTabBarController())
                }
            case .failure(let error):
                print("Failed to save device: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "There was an error deleting the device, please try again later.")
                }
            }
        }
    }
}
