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
        NotificationsManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    private func createViewModels() {
        models.forEach({ model in
            guard let type = NotificationsManager.IGType(rawValue: model.notificationType) else {
                return
            }
            let username = model.username
            guard let profilePictureUrl = URL(string: model.profilePictureUrl) else {
                return
            }
            
            // Derive
            
            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            username: username,
                            profilePictureURL: profilePictureUrl,
                            postURL: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            username: username,
                            profilePictureURL: profilePictureUrl,
                            postURL: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else {
                    return
                }
                viewModels.append(
                    .follow(
                        viewModel: FollowNotificationCellViewModel(
                            username: username,
                            profilePictureURL: profilePictureUrl,
                            isCurrentUserFollowing: isFollowing,
                            date: model.dateString
                        )
                    )
                )
            }
        })
        
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
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
                    postURL: postUrl,
                    date: "May 29"
                )
            ),
            
                .comment(
                    viewModel: CommentNotificationCellViewModel(
                        username: "jeff342342",
                        profilePictureURL: iconUrl,
                        postURL: postUrl,
                        date: "May 29"
                    )
                ),
            
                .follow(viewModel:
                            FollowNotificationCellViewModel(
                                username: "kate",
                                profilePictureURL: iconUrl,
                                isCurrentUserFollowing: true,
                                date: "May 29"
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
        
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            guard let user = user else {
                let alert = UIAlertController(title: "Woops",
                                              message: "User doesn't exist",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
}

// MARK: - Actions

extension NotificationsViewController: FollowNotificationTableViewCellDelegate, LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate {
    
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell,
                                         didTapButton isFollowing: Bool,
                                         viewModel: FollowNotificationCellViewModel) {
        let username = viewModel.username
        DatabaseManager.shared.updateRelationship(
            state: isFollowing ? .follow : .unfollow,
            for: username
        ) { [weak self] success in
            if !success {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Woops",
                                                  message: "Unable to perform action.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                }
            }
        }
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
        
        // Find post by id from target user
        DatabaseManager.shared.getPost(
            with: postID,
            from: username
        ) { [weak self] post in
            
            DispatchQueue.main.async {
                guard let post = post else {
                    let alert = UIAlertController(title: "Oops",
                                                  message: "We are unable to open this post.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                    return
                }
                
                let vc = PostViewController(post: post, owner: username)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

