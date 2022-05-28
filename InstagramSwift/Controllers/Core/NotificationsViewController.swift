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
    private var models: [IGNotification] = []
    
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
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LikeNotificationTableViewCell.identifier,
                for: indexPath
            ) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentNotificationTableViewCell.identifier,
                for: indexPath
            ) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
     
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        }
        
        // FixME: Update function to use username (the one bellow is for an email)
//        DatabaseManager.shared.findUser(with: username) { [weak self] user in
//            guard let user = user else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                let vc = ProfileViewController(user: user)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }
//
//        }
        
    }
    
}

// MARK: - Actions

extension NotificationsViewController: FollowNotificationTableViewCellDelegate, LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate {
    
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell,
                                         didTapButton isFollowing: Bool,
                                         viewModel: FollowNotificationCellViewModel) {
        let username = viewModel.username
//        DatabaseManager.shared.updateRelationship(
//            state: isFollowing ? .follow : .unfollow,
//            for: username
//        ) { success in
//
//        }
    }
    
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell,
                                       didTapPostWith viewModel: LikeNotificationCellViewModel) {
        
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .comment:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
    }
    
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell,
                                          didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .like:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
    }
    
    func openPost(with index: Int, username: String) {
        print(index)
        
        guard index < models.count else {
            return
        }
        
        let model = models[index]
        let username = username
        guard let postID = model.postId else {
            return
        }
    }
    
}

