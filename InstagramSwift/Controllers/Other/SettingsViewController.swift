//
//  SettingsViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var sections: [SettingsSection] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose))
        
        createTableFooter()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func configureModels() {
        sections.append(
            SettingsSection(title: "App", options: [
                SettingOption(
                    title: "Rate App",
                    image: UIImage(systemName: "star"),
                    color: .systemOrange,
                    handler: {
                        guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {
                            return
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }),
                
                SettingOption(
                    title: "Share App",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    color: .systemBlue,
                    handler: { [weak self] in
                        guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {
                            return
                        }
                        DispatchQueue.main.async {
                            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                            self?.present(vc, animated: true, completion: nil)
                        }
                    }),
            ])
        )
        
        sections.append(
            SettingsSection(title: "Information", options: [
                SettingOption(
                    title: "Terms of Service",
                    image: UIImage(systemName: "doc"),
                    color: .systemPink,
                    handler: { [weak self] in
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://help.instagram.com/581066165581870?helpref=page_content") else {
                                return
                            }
                            let vc = SFSafariViewController(url: url)
                            self?.present(vc, animated: true, completion: nil)
                        }
                    }),
                
                SettingOption(
                    title: "Privacy Policy",
                    image: UIImage(systemName: "hand.raised"),
                    color: .systemGreen,
                    handler: { [weak self] in
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://help.instagram.com/519522125107875") else {
                                return
                            }
                            let vc = SFSafariViewController(url: url)
                            self?.present(vc, animated: true, completion: nil)
                        }
                    }),
                
                SettingOption(
                    title: "Get Help",
                    image: UIImage(systemName: "message"),
                    color: .systemPurple,
                    handler: { [weak self] in
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://help.instagram.com/") else {
                                return
                            }
                            let vc = SFSafariViewController(url: url)
                            self?.present(vc, animated: true, completion: nil)
                        }
                    }),
            ])
        )
    }
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true
        
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        
        tableView.tableFooterView = footer
    }
    
    @objc private func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Sign Out",
                                            message: "Are you sure?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
}

// TableView
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
