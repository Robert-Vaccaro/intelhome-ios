//
//  EnterNameVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/21/24.
//

import UIKit

class EnterNameVC: BaseVC, UITextFieldDelegate {
    
    // MARK: - UI Elements
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What's your name?"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your name to complete registration"
        label.font = UIFont.systemFont(ofSize: subTitleFontSize, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let firstNameInputView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lastNameInputView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First name"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last name"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
    
    private var buttonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        firstNameTextField.becomeFirstResponder() // Make first name field first responder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers
    }
    
    private func setupUI() {
        // Add subviews
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(firstNameInputView)
        firstNameInputView.addSubview(firstNameTextField)
        view.addSubview(lastNameInputView)
        lastNameInputView.addSubview(lastNameTextField)
        view.addSubview(continueButton)
        
        // Set up button action
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(validateNames), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Layout constraints
        buttonBottomConstraint = continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // First Name Input View
            firstNameInputView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            firstNameInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            firstNameInputView.heightAnchor.constraint(equalToConstant: 50),

            // First Name Text Field
            firstNameTextField.leadingAnchor.constraint(equalTo: firstNameInputView.leadingAnchor, constant: 10),
            firstNameTextField.trailingAnchor.constraint(equalTo: firstNameInputView.trailingAnchor, constant: -10),
            firstNameTextField.centerYAnchor.constraint(equalTo: firstNameInputView.centerYAnchor),
            
            // Last Name Input View
            lastNameInputView.topAnchor.constraint(equalTo: firstNameInputView.bottomAnchor, constant: 20),
            lastNameInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lastNameInputView.heightAnchor.constraint(equalToConstant: 50),

            // Last Name Text Field
            lastNameTextField.leadingAnchor.constraint(equalTo: lastNameInputView.leadingAnchor, constant: 10),
            lastNameTextField.trailingAnchor.constraint(equalTo: lastNameInputView.trailingAnchor, constant: -10),
            lastNameTextField.centerYAnchor.constraint(equalTo: lastNameInputView.centerYAnchor),
            
            // Continue Button
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            buttonBottomConstraint
        ])
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        buttonBottomConstraint.constant = -keyboardHeight - 16
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        buttonBottomConstraint.constant = -16
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            // Move focus to the last name field
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            // Dismiss keyboard when return is pressed on last name field
            lastNameTextField.resignFirstResponder()
        }
        return true
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
    
    @objc private func validateNames() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty else {
            self.showAlert(message: "Please enter both first and last names.")
            return
        }
        let parameters = [
            "firstName": firstName,
            "lastName": lastName,
        ]
        makeAPICall(path: "/users/save-name", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
            switch(results) {
            case .success(let data):
                if let error = data.error, error == "User not found" {
                    self.showAlert(message: "There was an error saving your name. Please try again.")
                }
                self.saveUserSession(user: data.user, tokens: data.tokens)
                self.goToVC(vc: MainTabBarController(), animated: false)
            case.failure(let error):
                print(error)
                self.showAlert(message: "There was an error saving your name. Please try again.")
            }
        }
    }
}
