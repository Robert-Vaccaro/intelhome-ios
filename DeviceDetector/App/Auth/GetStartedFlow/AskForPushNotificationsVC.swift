//
//  AskForPushNotificationsVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//
import UIKit

class AskForPushNotificationsVC: BaseVC {
    
    // MARK: - UI Elements
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let topPlaceholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "push-notifications") // Placeholder image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Push Notifications"
        label.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Turn on notifications to make sure to keep on your devices up to date."
        label.font = UIFont.systemFont(ofSize: subTitleFontSize)
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupUI()
    }
    
    private func setupUI() {
        // Add subviews
        view.addSubview(backButton)
        view.addSubview(topPlaceholderImage)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(continueButton)
        
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(getStartedButtonPressed), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Placeholder Image
            topPlaceholderImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            topPlaceholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topPlaceholderImage.widthAnchor.constraint(equalToConstant: self.view.frame.size.width),
            topPlaceholderImage.heightAnchor.constraint(equalToConstant: 300),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topPlaceholderImage.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Continue Button
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    // MARK: - Actions
    @objc private func dismissVC() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil) // Set animated to false since the transition handles the animation
    }
    @objc private func openStorysetLink() {
        guard let url = URL(string: "https://storyset.com/technology") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func getStartedButtonPressed() {
        registerForPushNotifications { authorized in
            self.goToVC(vc: EnterPhoneVC())
        }
    }
}
