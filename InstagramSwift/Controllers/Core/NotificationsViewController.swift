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
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(LikeNotificationTableViewCell.self,
                       forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        
        table.register(CommentNotificationTableViewCell.self,
                       forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        
        table.register(FollowNotificationTableViewCell.self,
                       forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        return table
    }()
    
    private var viewModels: [NotificationCellType] = []
    
    //MARK: - Lifecycle

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
        mockData()
    }
    
    private func mockData() {
        tableView.isHidden = false
        
        guard let postUrl = URL(string: "https://images.pexels.com/photos/347141/pexels-photo-347141.jpeg") else {
            return
        }
        
        guard let iconUrl = URL(string: "https://images.pexels.com/photos/874158/pexels-photo-874158.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2") else {
            return
        }
        
        viewModels = [
            .like(
                viewModel: LikeNotificationCellViewModel(
                    username: "eric",
                    profilePictureURL: iconUrl,
                    postURL: postUrl
                )
            ),
            
                .comment(
                    viewModel: CommentNotificationCellViewModel(
                        username: "jeff342342",
                        profilePictureURL: iconUrl,
                        postURL: postUrl
                    )
                ),
            
                .follow(viewModel:
                            FollowNotificationCellViewModel(
                                username: "kate",
                                profilePictureURL: iconUrl,
                                isCurrentUserFollowing: true
                            )
                       ),
            
        ]
        tableView.reloadData()
    }

}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FollowNotificationTableViewCell.identifier,
                for: indexPath
            ) as? FollowNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LikeNotificationTableViewCell.identifier,
                for: indexPath
            ) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentNotificationTableViewCell.identifier,
                for: indexPath
            ) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
     
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
