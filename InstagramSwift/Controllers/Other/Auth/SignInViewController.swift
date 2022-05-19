//
//  SignInViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    //Subviews
    private let headerView = SignInHeaderView()
    
    private let emailField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Password"
        field.keyboardType = .default
        field.isSecureTextEntry = true
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Create Account", for: .normal)
        return button
    }()
    
    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Terms of Service", for: .normal)
        return button
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        headerView.backgroundColor = .red
        addSubviews()
        
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: (view.height - view.safeAreaInsets.top)/3
        )
        
        emailField.frame = CGRect(
            x: 25,
            y: headerView.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        
        passwordField.frame = CGRect(
            x: 25,
            y: emailField.bottom + 10,
            width: view.width - 50,
            height: 50
        )
        
        signInButton.frame = CGRect(
            x: 35,
            y: passwordField.bottom + 20,
            width: view.width - 70,
            height: 50
        )
        
        createAccountButton.frame = CGRect(
            x: 35,
            y: signInButton.bottom + 20,
            width: view.width - 70,
            height: 50
        )
        
        termsButton.frame = CGRect(
            x: 35,
            y: createAccountButton.bottom + 50,
            width: view.width - 70,
            height: 40
        )
        
        privacyButton.frame = CGRect(
            x: 35,
            y: termsButton.bottom + 10,
            width: view.width - 70,
            height: 40
        )
    }
    
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addButtonActions() {
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc private func didTapSignInButton() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        
        // Sign In with authManager
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc private func didTapCreateAccountButton() {
        let vc = SignUpViewController()
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapPrivacyButton() {
        guard let url = URL(string: "https://www.instagram.com") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    @objc private func didTapTermsButton() {
        guard let url = URL(string: "https://www.instagram.com") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    //MARK: Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            didTapSignInButton()
        }
        
        return true
    }
    
}
