//
//  SignInVC.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//
import UIKit

class EnterPhoneVC: BaseVC, UITextFieldDelegate {
    
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
        label.text = "Welcome"
        label.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "To sign up or log in, enter your number"
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
    
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone number"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .phonePad
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let continueWithPhoneButton: UIButton = {
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
        UIApplication.shared.registerForRemoteNotifications()
        setupUI()
        setupKeyboardObservers()
        phoneNumberTextField.becomeFirstResponder() // Make text field first responder
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers
    }
    
    private func setupUI() {
        // Add subviews
        phoneNumberTextField.delegate = self
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(phoneInputView)
        phoneInputView.addSubview(phoneNumberTextField)
        view.addSubview(continueWithPhoneButton)
        
        // Set up button action
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        continueWithPhoneButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Layout constraints
        buttonBottomConstraint = continueWithPhoneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
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

            // Phone Number Text Field
            phoneNumberTextField.leadingAnchor.constraint(equalTo: phoneInputView.leadingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneInputView.trailingAnchor, constant: -10),
            phoneNumberTextField.centerYAnchor.constraint(equalTo: phoneInputView.centerYAnchor),
            
            // Continue with Phone Button
            continueWithPhoneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueWithPhoneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueWithPhoneButton.heightAnchor.constraint(equalToConstant: 50),
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
    
    @objc private func continueButtonPressed() {
        guard let phoneNumber = phoneNumberTextField.text else {
            print("Phone number field is empty.")
            return
        }
        
        // Remove occurrences of "-"
        let sanitizedNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        // Check if it's exactly 10 digits
        if sanitizedNumber.count == 10 && sanitizedNumber.allSatisfy({ $0.isNumber }) {
            let parameters = [
                "phone": "+1\(sanitizedNumber)",
                "DTString": SessionData.DTString
            ]
            makeAPICall(path: "/users/enter-phone", method: .POST, parameters: parameters, responseType: UserTokens.self) { results in
                switch(results) {
                case .success(let data):
                    print(data)
                    if let tokens = data.tokens {
                        self.saveUserSession(user: nil, tokens: data.tokens)
                    }
                    self.goToVC(vc: VerifyPhoneVC())
                case.failure(let error):
                    print(error)
                    self.showAlert(message: "There was an error, please try again later")
                }
            }
        } else {
            self.showAlert(message: "Invalid phone number. Please enter a 10-digit number.")
        }
    }
    
    func enterPhone(completion: @escaping (Result<UserTokens, Error>) -> Void) {

    }
    
    // MARK: - TextField Delegate for Formatting
      func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          guard let text = textField.text else { return true }
          
          // Get the new text by replacing the range with the new string
          let newText = (text as NSString).replacingCharacters(in: range, with: string)
          let digits = newText.filter { $0.isNumber }
          
          // Limit to 10 digits
          guard digits.count <= 10 else { return false }
          
          // Format the text based on the number of digits
          let formattedText: String
          switch digits.count {
          case 0...3:
              formattedText = digits
          case 4...6:
              let areaCode = String(digits.prefix(3))
              let middlePart = String(digits.suffix(digits.count - 3))
              formattedText = "\(areaCode)-\(middlePart)"
          case 7...10:
              let areaCode = String(digits.prefix(3))
              let middlePart = String(digits[digits.index(digits.startIndex, offsetBy: 3)..<digits.index(digits.startIndex, offsetBy: 6)])
              let lastPart = String(digits.suffix(digits.count - 6))
              formattedText = "\(areaCode)-\(middlePart)-\(lastPart)"
          default:
              formattedText = digits
          }
          
          textField.text = formattedText
          return false
      }
}
