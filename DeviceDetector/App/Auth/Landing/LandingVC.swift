//
//  LandingVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import UIKit
import UserNotifications

class LandingVC: BaseVC {
    
    // MARK: - UI Elements
    private let topPlaceholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "get-started") // Placeholder image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "IntelHome"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep Your Home Updated"
        label.font = UIFont.systemFont(ofSize: subTitleFontSize)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let footerLinkButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: "Technology illustrations by Storyset",
            attributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.lightGray,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupUI()
        setupLongPressGesture()
    }
    
    private func setupUI() {
        // Add subviews
        view.addSubview(topPlaceholderImage)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(getStartedButton)
        view.addSubview(footerLinkButton)
        
        // Set up footer link button action
        footerLinkButton.addTarget(self, action: #selector(openStorysetLink), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(getStartedButtonPressed), for: .touchUpInside)
        // Layout constraints
        NSLayoutConstraint.activate([
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
            
            // Get Started Button
            getStartedButton.bottomAnchor.constraint(equalTo: footerLinkButton.topAnchor, constant: -16),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Footer Link Button
            footerLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerLinkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        topPlaceholderImage.isUserInteractionEnabled = true // Enable user interaction for imageView
        topPlaceholderImage.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Actions
    @objc private func openStorysetLink() {
        guard let url = URL(string: "https://storyset.com/technology") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func getStartedButtonPressed() {
        self.checkNotificationSettingsAndRegister { (status) in
            switch(status){
            case .notDetermined:
                self.goToVC(vc: AskForPushNotificationsVC())
            default:
                self.goToVC(vc: EnterPhoneVC())
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            showSecretSignInAlert()
        }
    }
    
    func showSecretSignInAlert() {
        let alertController = UIAlertController(title: "Password Required",
                                                message: "",
                                                preferredStyle: .alert)
        
        // Add text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.borderStyle = .roundedRect
        }
        
        // Submit action
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            // Access the text field value
            if let password = alertController.textFields?.first?.text {
                let parameters = [
                    "password": password
                ]
                self.makeAPICall(path: "/users/demo-sign-in", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
                    switch(results) {
                    case .success(let data):
                        if let user = data.user, let tokens = data.tokens {
                            self.saveUserSession(user: user, tokens: tokens)
                            self.goToVC(vc: MainTabBarController())
                        } else {
                            self.showAlert(message: "The password is incorrect, please try again")
                        }
                    case.failure(let error):
                        print(error)
                        self.showAlert(message: "There was an error, please try again later")
                    }
                }
            }
        }
        
        // Close action
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        // Add actions to the alert
        alertController.addAction(submitAction)
        alertController.addAction(closeAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
}
