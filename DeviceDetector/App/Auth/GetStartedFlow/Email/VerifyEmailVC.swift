//
//  VerifyEmailVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/21/24.
//
import UIKit

class VerifyEmailVC: BaseVC, UITextFieldDelegate {
    
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
        label.text = "Email Verification"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "We sent you a code to make sure it's your email"
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
    
    private let emailCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "1234"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let resendCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        emailCodeTextField.becomeFirstResponder() // Make text field first responder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers
    }
    
    private func setupUI() {
        // Add subviews
        emailCodeTextField.delegate = self
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailInputView)
        emailInputView.addSubview(emailCodeTextField)
        view.addSubview(resendCodeButton)
        view.addSubview(continueButton)
        
        // Set up button action
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        resendCodeButton.addTarget(self, action: #selector(resendEmailCode), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(checkEmailCode), for: .touchUpInside)

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
            
            // Email Input View
            emailInputView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            emailInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailInputView.heightAnchor.constraint(equalToConstant: 50),

            // Email Code Text Field
            emailCodeTextField.leadingAnchor.constraint(equalTo: emailInputView.leadingAnchor, constant: 10),
            emailCodeTextField.trailingAnchor.constraint(equalTo: emailInputView.trailingAnchor, constant: -10),
            emailCodeTextField.centerYAnchor.constraint(equalTo: emailInputView.centerYAnchor),
            
            // Resend Code Button
            resendCodeButton.topAnchor.constraint(equalTo: emailInputView.bottomAnchor, constant: 20),
            resendCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
    
    @objc func resendEmailCode() {
        let parameters = [
            "":"",
        ]
        makeAPICall(path: "/users/resend-email-code", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
            switch(results) {
            case .success(let data):
                print(data)
            case.failure(let error):
                print(error)
            }
        }
    }
    
    
    @objc func checkEmailCode() {
        guard let code = emailCodeTextField.text, !code.isEmpty else {
            self.showAlert(message: "Please enter a code.")
            return
        }
        
        let parameters = [
            "code": code,
        ]
        
        makeAPICall(path: "/users/check-email-code", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
            switch results {
            case .success(let data):
                print(data)
                if let message = data.message, message == "Email verified" {
                    // Successful verification
                    self.goToVC(vc: EnterNameVC())
                } else if let error = data.error {
                    switch error {
                    case "Code expired":
                        self.showAlert(message: "The code has expired. Please request a new code.", buttonTitle: "Try Again") { _ in
                            self.dismiss(animated: true)
                        }
                    case "Invalid code":
                        self.showAlert(message: "The code you entered is invalid. Please check and try again.")
                    case "User not found":
                        self.showAlert(message: "No account associated with this email. Please ensure you’ve signed up.")
                    default:
                        self.showAlert(message: "There was an error verifying your email. Please try again.")
                    }
                } else {
                    self.showAlert(message: "There was an error verifying your email. Please try again.")
                }
            case .failure(let error):
                print("Error:", error)
                self.showAlert(message: "There was an error verifying your email. Please try again.")
            }
        }
    }

    
}
