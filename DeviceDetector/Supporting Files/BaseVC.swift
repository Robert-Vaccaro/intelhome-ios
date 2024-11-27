//
//  BaseVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import UIKit

class BaseVC: UIViewController {
    let activityIndicator = UIActivityIndicatorView(style: .large)

    let grayGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            #colorLiteral(red: 0.1306995749, green: 0.1306995749, blue: 0.1306995749, alpha: 1).cgColor,
            UIColor.black.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(grayGradient, at: 0)
        setupActivityIndicator() // Setup the activity indicator
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient covers the entire view
        grayGradient.frame = view.bounds
    }

    func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.tintColor = primaryColor
        activityIndicator.backgroundColor = .black
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.layer.shadowColor = primaryColor.cgColor
        activityIndicator.layer.shadowOpacity = 0.5
        activityIndicator.layer.shadowOffset = CGSize(width: 0, height: -1)
        activityIndicator.layer.shadowRadius = 3
        activityIndicator.layer.masksToBounds = false
        activityIndicator.layer.zPosition = 10000
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 75),
            activityIndicator.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func goToVC(vc: UIViewController, animated: Bool = true, animationType: CATransitionType = .push, direction: CATransitionSubtype = .fromRight) {
        DispatchQueue.main.async {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
//            if animated {
//                // Create a custom transition
//                let transition = CATransition()
//                transition.duration = 0.5
//                transition.type = animationType
//                transition.subtype = direction
//                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//
//                // Apply the transition
//                self.view.window?.layer.add(transition, forKey: kCATransition)
//                self.present(vc, animated: false, completion: nil)
//            } else {
//                vc.modalTransitionStyle = .crossDissolve
//                self.present(vc, animated: true, completion: nil)
//            }
        }
    }
    
    func saveUserSession(user: User?, tokens: Tokens?) {
        if let user = user {
            SessionData.user = user
            if let locations = user.locations, let location = locations.first {
                SessionData.currectLocation = location
            } else {
                SessionData.currectLocation = "All"
            }
        }

        if let tokens = tokens {
            SessionData.accessToken = tokens.accessToken
            SessionData.refreshToken = tokens.refreshToken
            KeychainHelper.storeRefreshToken(tokens.refreshToken)
        }
        print("Session saved successfully")
    }

    func showAlert(title: String = "Error", message: String, buttonTitle: String = "OK", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteAccount () {
        self.makeAPICall(
            path: "/users",
            method: .DELETE,
            responseType: BasicRes.self
        ) { result in
            switch result {
            case .success(let data):
                if let error = data.error {
                    self.showAlert(message: "There was an error deleting your account, please try again.")
                } else {
                    self.signOut()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showAlert(message: "There was an error deleting your account, please try again.")
            }
        }
    }
    
    func signOut() {
        SessionData.user = nil
        SessionData.refreshToken = ""
        SessionData.accessToken = ""
        KeychainHelper.deleteRefreshToken()
        goToVC(vc: LandingVC())
    }
    
    func updateDeviceField(deviceId: String, location: String? = nil, needsUpdate: Bool? = nil) {
        var parameters: [String: Any] = [
            "deviceId": deviceId
        ]
        
        // Add optional fields if provided
        if let location = location {
            parameters["location"] = location
        }
        if let needsUpdate = needsUpdate {
            parameters["needsUpdate"] = needsUpdate
        }
        
        makeAPICall(
            path: "/devices/update",
            method: .PUT,
            parameters: parameters,
            responseType: CreatedDeviceResponse.self
        ) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.goToVC(vc: MainTabBarController())
                }
            case .failure(let error):
                print("Failed to update device: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to update the device. Please try again.")
                }
            }
        }
    }
    // MARK: - Fetch Notifications
    func fetchNotifications(completion: @escaping (Bool) -> Void) {
        makeAPICall(
            path: "/notifications/",
            method: .GET,
            responseType: [AppNotification].self
        ) { result in
            switch result {
            case .success(let fetchedNotifications):
                SessionData.notifications = fetchedNotifications
                completion(true)
            case .failure(let error):
                print("Failed to fetch notifications: \(error.localizedDescription)")
                completion(true)
                self.showAlert(message: "Failed to load notifications. Please try again later.")
            }
        }
    }
}
