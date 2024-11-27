//
//  EnterEmailVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/21/24.
//
import UIKit

class EnterEmailVC: BaseVC, UITextFieldDelegate {
    
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
        label.text = "What's your email?"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter a valid email"
        label.font = UIFont.systemFont(ofSize: subTitleFontSize, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailInputView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .emailAddress
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let continueWithEmailButton: UIButton = {
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
        emailTextField.becomeFirstResponder() // Make text field first responder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers
    }
    
    private func setupUI() {
        // Add subviews
        emailTextField.delegate = self
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailInputView)
        emailInputView.addSubview(emailTextField)
        view.addSubview(continueWithEmailButton)
        
        // Set up button action
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        continueWithEmailButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Layout constraints
        buttonBottomConstraint = continueWithEmailButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
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
            
            // Email Input View
            emailInputView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            emailInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailInputView.heightAnchor.constraint(equalToConstant: 50),

            // Email Text Field
            emailTextField.leadingAnchor.constraint(equalTo: emailInputView.leadingAnchor, constant: 10),
            emailTextField.trailingAnchor.constraint(equalTo: emailInputView.trailingAnchor, constant: -10),
            emailTextField.centerYAnchor.constraint(equalTo: emailInputView.centerYAnchor),
            
            // Continue with Email Button
            continueWithEmailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueWithEmailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueWithEmailButton.heightAnchor.constraint(equalToConstant: 50),
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
        if textField == emailTextField {
            // Move focus to the last name field
            emailTextField.resignFirstResponder()
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
    
    @objc private func continueButtonPressed() {
        guard let email = emailTextField.text else {
            print("Email field is empty.")
            return
        }
        
        if isValidEmail(email) {
            print("Valid email: \(email)")
            let parameters = [
                "email": email,
            ]
            makeAPICall(path: "/users/enter-email", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
                switch(results) {
                case .success(let data):
                    if data.message == "Success" {
                        self.goToVC(vc: VerifyEmailVC())
                    } else if data.error == "User not found" {
                        self.showAlert(message: "There was an error sending the code, please try again later.") { _ in
                            self.goToVC(vc: LandingVC())
                        }
                    }
                case.failure(let error):
                    print(error)
                    self.showAlert(message: "There was an error sending the code, please try again later.")
                }
            }
        } else {
            self.showAlert(message: "Invalid email address. Please enter a valid email.")
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
