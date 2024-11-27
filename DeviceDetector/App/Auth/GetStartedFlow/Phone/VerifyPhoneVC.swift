//
//  CheckPhoneVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/21/24.
//
import UIKit

class VerifyPhoneVC: BaseVC, UITextFieldDelegate {
    
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
        label.text = "Phone Verification"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "We sent you a code to make sure it's your phone"
        label.font = UIFont.systemFont(ofSize: subTitleFontSize, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let phoneInputView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let phoneCodeTextField: UITextField = {
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
        phoneCodeTextField.becomeFirstResponder() // Make text field first responder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers
    }
    
    private func setupUI() {
        // Add subviews
        phoneCodeTextField.delegate = self
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(phoneInputView)
        phoneInputView.addSubview(phoneCodeTextField)
        view.addSubview(resendCodeButton)
        view.addSubview(continueButton)
        
        // Set up button action
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        resendCodeButton.addTarget(self, action: #selector(resendPhoneCode), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(checkPhoneCode), for: .touchUpInside)

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
            
            // Phone Input View
            phoneInputView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            phoneInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneInputView.heightAnchor.constraint(equalToConstant: 50),

            // Phone Code Text Field
            phoneCodeTextField.leadingAnchor.constraint(equalTo: phoneInputView.leadingAnchor, constant: 10),
            phoneCodeTextField.trailingAnchor.constraint(equalTo: phoneInputView.trailingAnchor, constant: -10),
            phoneCodeTextField.centerYAnchor.constraint(equalTo: phoneInputView.centerYAnchor),
            
            // Resend Code Button
            resendCodeButton.topAnchor.constraint(equalTo: phoneInputView.bottomAnchor, constant: 20),
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
    
    @objc func resendPhoneCode() {
        let parameters = [
            "":"",
        ]
        makeAPICall(path: "/users/resend-phone-code", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
            switch(results) {
            case .success(let data):
                print(data)
            case.failure(let error):
                print(error)
                self.showAlert(message: "There was an error sending the code, please try again later.")
            }
        }
    }
    
    
    @objc func checkPhoneCode() {
        guard let code = phoneCodeTextField.text else {
            self.showAlert(message: "Please enter in a code.")
            return
        }
        
        let parameters = [
            "code": code,
        ]
        makeAPICall(path: "/users/check-phone-code", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
            switch(results) {
            case .success(let data):
                if let user = data.user, let tokens = data.tokens {
                    self.saveUserSession(user: data.user, tokens: data.tokens)
                    if user.emailVerification == true {
                        if user.firstName.isEmpty || user.lastName.isEmpty {
                            self.goToVC(vc: EnterNameVC())
                        } else {
                            self.goToVC(vc: MainTabBarController())
                        }
                    } else {
                        self.goToVC(vc: EnterEmailVC())
                    }
                } else {
                    self.showAlert(message: "There was an error checking the code, please try again.")
                }
            case.failure(let error):
                print(error)
                self.showAlert(message: "There was an error checking the code, please try again.")

            }
        }
    }
}
