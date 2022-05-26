//
//  NotificationsViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(LikeNotificationTableViewCell.self,
                       forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        
        table.register(CommentNotificationTableViewCell.self,
                       forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        
        table.register(FollowNotificationTableViewCell.self,
                       forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noActivityLabel)
        tableView.delegate = self
        tableView.dataSource = self
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications() {
        noActivityLabel.isHidden = false
    }

}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    
}
