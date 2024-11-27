//
//  ProfileVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//
import UIKit

class AccountVC: BaseVC {
    
    var user: User? = SessionData.user
    private var bellButton: UIBarButtonItem!
    private var bellImageView: UIImageView!
    private var notificationBadgeView: UIView!
    private var animationTimer:Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stopBellShake() // reset animation
        fetchNotifications { _ in
            self.setupNavigationBar()
            self.setupUI()
        }
    }
    private func setupNavigationBar() {
        title = "Account"
        
        // Create bell button with custom view
        bellImageView = UIImageView(image: UIImage(systemName: "bell"))
        bellImageView.tintColor = .label
        bellImageView.contentMode = .scaleAspectFit
        bellImageView.tintColor = primaryColor
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add a badge view to the bell icon
        notificationBadgeView = UIView()
        notificationBadgeView.backgroundColor = .red
        notificationBadgeView.layer.cornerRadius = 6
        notificationBadgeView.clipsToBounds = true
        notificationBadgeView.translatesAutoresizingMaskIntoConstraints = false
        notificationBadgeView.isHidden = SessionData.notifications.isEmpty
        
        let customBellView = UIView()
        customBellView.addSubview(bellImageView)
        customBellView.addSubview(notificationBadgeView)
        
        NSLayoutConstraint.activate([
            bellImageView.centerXAnchor.constraint(equalTo: customBellView.centerXAnchor),
            bellImageView.centerYAnchor.constraint(equalTo: customBellView.centerYAnchor),
            bellImageView.widthAnchor.constraint(equalToConstant: 30),
            bellImageView.heightAnchor.constraint(equalToConstant: 30),
            
            notificationBadgeView.widthAnchor.constraint(equalToConstant: 12),
            notificationBadgeView.heightAnchor.constraint(equalToConstant: 12),
            notificationBadgeView.topAnchor.constraint(equalTo: bellImageView.topAnchor, constant: -4),
            notificationBadgeView.trailingAnchor.constraint(equalTo: bellImageView.trailingAnchor, constant: 4),
            
            customBellView.widthAnchor.constraint(equalToConstant: 30),
            customBellView.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        customBellView.isUserInteractionEnabled = true
        
        // Add tap gesture to the custom bell view
        let bellTapGesture = UITapGestureRecognizer(target: self, action: #selector(bellTapped))
        customBellView.addGestureRecognizer(bellTapGesture)
        
        bellButton = UIBarButtonItem(customView: customBellView)
        navigationItem.leftBarButtonItem = bellButton
        
        // Gear button
        let gearButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(gearButtonTapped)
        )
        gearButton.tintColor = primaryColor
        navigationItem.rightBarButtonItem = gearButton
        
        // Initial badge check
        checkAndUpdateNotificationBadge()
    }
    
    private func setupUI() {
        guard let user = user else { return }
        
        // Profile photo
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Load profile image from URL
        if let url = URL(string: user.profilePhoto) {
            loadImage(from: url, into: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "person-image") // Fallback image
        }
        
        // User info labels
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .white
        
        let emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.text = "\(user.email)"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .lightGray
        
        let phoneLabel = UILabel()
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.text = "\(user.phone)"
        phoneLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        phoneLabel.textColor = .lightGray

        // Add subviews
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(phoneLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            phoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        startBellAnimationIfNeeded()
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
    
    private func startBellAnimationIfNeeded() {
        guard SessionData.notifications.count > 0 else { return }

        // Show the badge
        notificationBadgeView.isHidden = false

        // Shake animation using Timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.animateBellShake(view: self.bellImageView)
        }
    }

    func animateBellShake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.values = [0, -0.5, 0.5, -0.3, 0.3, -0.1, 0.1, 0] // Adjust these values for more or less swing
        animation.keyTimes = [0, 0.1, 0.3, 0.5, 0.7, 0.8, 0.9, 1]
        animation.duration = 0.6 // Adjust the duration for faster/slower swing
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(animation, forKey: "bellShake")
    }
    
    private func stopBellShake() {
        if animationTimer != nil {
            animationTimer.invalidate()
            animationTimer = nil
        }
        bellImageView?.layer.removeAnimation(forKey: "bellShake")
    }
    
    private func checkAndUpdateNotificationBadge() {
        DispatchQueue.main.async {
            self.notificationBadgeView.isHidden = SessionData.notifications.isEmpty
        }
    }
    
    @objc private func bellTapped() {
        navigationController?.pushViewController(NotificationsVC(), animated: true)
    }
    
    @objc private func gearButtonTapped() {
        navigationController?.pushViewController(AccountSettingsVC(), animated: true)
    }
}
