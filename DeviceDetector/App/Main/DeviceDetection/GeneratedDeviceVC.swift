//
//  SpecificDeviceVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/23/24.
//
import UIKit

class GeneratedDeviceVC: BaseVC {

    // MARK: - Properties
    private var deviceName: String?
    private var device: Device?
    private var chosenLocation: String?

    private let noDeviceLabel: UILabel = {
        let label = UILabel()
        label.text = """
No device information found

Please go back and try again
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
    // MARK: - Initializer
    init(deviceName: String?) {
        self.deviceName = deviceName
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
        if let deviceName = deviceName {
            getDeviceInfo(name: deviceName) { result in
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
        navigationController?.navigationBar.backgroundColor = .clear

        guard let device = device else {
            showNoDeviceMessage()
            return
        }

        // Setup Tabs
        setupTabs()

        // Create a scroll view and content view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(saveDevice)
        )
        
        // "Pick a Location" Label
        let locationLabel = UILabel()
        locationLabel.text = "Pick a Location"
        locationLabel.font = UIFont.boldSystemFont(ofSize: 20)
        locationLabel.textColor = .lightGray
        locationLabel.textColor = .white
        locationLabel.textAlignment = .center
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)

        // Add tabScrollView and tabStackView to the contentView
        contentView.addSubview(tabScrollView)
        tabScrollView.addSubview(tabStackView)

        // Create views for device properties
        let nameView = createPropertyView(title: "Device Name", value: device.name)
        let typeView = createPropertyView(title: "Device Type", value: device.type)
        let capabilitiesView = createListView(title: "Capabilities", values: device.capabilities)
        let specificationsView = createListView(
            title: "Specifications",
            values: device.specifications.components(separatedBy: ",")
        )
        let detectedAtView = createPropertyView(title: "Detected At", value: formatTimestamp(device.detectedAt))
        let needsUpdateView = createPropertyView(title: "Needs Update", value: device.needsUpdate ? "Yes" : "No")

        // Stack the views vertically
        let stackView = UIStackView(arrangedSubviews: [
            nameView,
            typeView,
            capabilitiesView,
            specificationsView,
            detectedAtView,
            needsUpdateView,
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        // Layout constraints for scrollView and contentView
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

            // Location Label
            locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationLabel.heightAnchor.constraint(equalToConstant: 40),

            // Tab Scroll View
            tabScrollView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            tabScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tabScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tabScrollView.heightAnchor.constraint(equalToConstant: 40),

            // Tab Stack View inside Tab Scroll View
            tabStackView.topAnchor.constraint(equalTo: tabScrollView.topAnchor),
            tabStackView.bottomAnchor.constraint(equalTo: tabScrollView.bottomAnchor),
            tabStackView.leadingAnchor.constraint(equalTo: tabScrollView.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: tabScrollView.trailingAnchor),

            // Stack View for Device Properties
            stackView.topAnchor.constraint(equalTo: tabScrollView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .right
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        // Layout constraints for title and value labels
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
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
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .right
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.numberOfLines = 0 // Allow multiple lines
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        valueLabel.attributedText = formatBulletPoints(values)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
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
        let parameters: [String: Any] = [
            "name": self.deviceName,
        ]

        makeAPICall(
            path: "/devices",
            method: .POST,
            parameters: parameters,
            responseType: CreatedDeviceResponse.self
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - Setup Tabs
    private func setupTabs() {
        // Clear all existing tabs
        for view in tabStackView.arrangedSubviews {
            tabStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
//        if let locations = SessionData.user.locations, let index = locations.firstIndex(of: "All") {
//            SessionData.user.locations?.remove(at: index)
//        }
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

            // Add tap gesture for each tab
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            tabLabel.addGestureRecognizer(tapGesture)

            tabStackView.addArrangedSubview(tabLabel)
        }

        // Select the first tab by default if available
        if let firstTab = tabStackView.arrangedSubviews.first as? UILabel {
            tabTapped(UITapGestureRecognizer(target: firstTab, action: nil))
        }
    }

    // MARK: - Handle Tab Tap
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let tabLabel = sender.view as? UILabel else { return }

        // Change the tab's text color to orange
        tabStackView.arrangedSubviews.forEach { subview in
            if let label = subview as? UILabel {
                label.textColor = .white
                label.backgroundColor = .clear
            }
        }
        device?.location = tabLabel.text ?? ""
        chosenLocation = tabLabel.text ?? ""
        tabLabel.textColor = .white
        tabLabel.backgroundColor = primaryColor
    }
    
    @objc func saveDevice() {
        guard let device = device else {
            showAlert(message: "Device information is missing.")
            return
        }
        guard let _ = chosenLocation else {
            showAlert(title: "Choose a Location", message: "Please choose a location before saving the device.")
            return
        }
        let parameters: [String: Any] = [
            "userId": device.userId,
            "name": device.name,
            "type": device.type,
            "location": device.location,
            "capabilities": device.capabilities,
            "specifications": device.specifications,
            "detectedAt": device.detectedAt,
            "needsUpdate": device.needsUpdate,
        ]

        makeAPICall(
            path: "/devices/save",
            method: .POST,
            parameters: parameters,
            responseType: CreatedDeviceResponse.self
        ) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.goToVC(vc: MainTabBarController())
                }
            case .failure(let error):
                print("Failed to save device: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "There was an error saving the device, please try again later.")
                }
            }
        }
    }

}
