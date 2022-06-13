//
//  PostViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit

class PostViewController: UIViewController {
    
    private let post: Post
    private let owner: String
    
    private var collectionView: UICollectionView?
    
    private var viewModels: [SinglePostCellType] = []
    
    private let commentBarView = CommentBarView()
    
    private var showObserver: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    // MARK: - Init
    init(post: Post, owner: String) {
        self.owner = owner
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemTeal
        
        configureCollectionView()
        view.addSubview(commentBarView)
        commentBarView.delegate = self
        fetchPost()
        observeKeyboardChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        commentBarView.frame = CGRect(
            x: 0,
            y: view.height-view.safeAreaInsets.bottom - 70,
            width: view.width,
            height: 70
        )
    }
    
    private func observeKeyboardChange() {
        showObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                return
            }
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height - 60 - height,
                    width: self.view.width,
                    height: 70
                )
            }
        }
        
        hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height - self.view.safeAreaInsets.bottom - 70,
                    width: self.view.width,
                    height: 70
                )
            }
        }
    }
    
    private func fetchPost() {
        let username = owner
        
        DatabaseManager.shared.getPost(with: post.id, from: username) { [weak self] post in
            guard let post = post else {
                return
            }
            self?.createViewModel(
                model: post,
                username: username,
                completion: { success in
                    guard success else {
                        print("failed to create VM")
                        return
                    }
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
        }
    }
    
    private func createViewModel(model: Post, username: String ,completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
            guard let strongSelf = self,
                  let postURL = URL(string: model.postUrlString),
                  let profilePictureURL = profilePictureURL else {
                completion(false)
                return
            }
            
            let isLiked = model.likers.contains(currentUsername)
            
            DatabaseManager.shared.getComments(
                postID: strongSelf.post.id,
                owner: strongSelf.owner) { comments in
                    var postData: [SinglePostCellType] = [
                        .poster(viewModel: PosterCollectionViewCellViewModel(
                            username: username,
                            profilePictureURL: profilePictureURL
                        )),
                        .post(viewModel: PostCollectionViewCellViewModel(
                            postURL: postURL
                        )),
                        .actions(viewModel: PostActionsCollectionViewCellViewModel(
                            isLiked: isLiked
                        )),
                        .likeCount(viewModel: PostLikesCollectionViewCellViewModel(
                            likers: model.likers
                        )),
                        .caption(viewModel: PostCaptionCollectionViewCellViewModel(
                            username: username,
                            caption: model.caption
                        )),
                    ]
                    
                    if let comment = comments.first {
                        postData.append(
                            .comment(viewModel: comment)
                        )
                    }
                    
                    postData.append(.timestamp(
                        viewModel: PostDatetimeCollectionViewCellViewModel(
                        date: DateFormatter.defaultFormatter.date(from: model.postedDate) ?? Date()
                    )))
                    
                    self?.viewModels = postData
                    completion(true)
                }
        }
    }
    
}

extension PostViewController: CommentBarViewDelegate {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        DatabaseManager.shared.createComments(comment: Comment(username: currentUsername,
                                                               comment: text,
                                                               dateString: String.date(with: Date())),
                                              postID: post.id,
                                              owner: owner) { sucess in
            DispatchQueue.main.async {
                guard sucess else {
                    return
                }
            }
        }
    }
}

extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType{
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifier,
                for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .actions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifier,
                for: indexPath) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifier,
                for: indexPath) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel, index: indexPath.section)
            cell.delegate = self
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifier,
                for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .timestamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifier,
                for: indexPath) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .comment(viewModel: let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommentCollectionViewCell.identifier,
                for: indexPath) as? CommentCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
    
}

extension PostViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let sheet = UIAlertController(title: "Post Actions",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let cellType = self?.viewModels[index]
                switch cellType {
                case .post(let viewModel):
                    let vc = UIActivityViewController(
                        activityItems: ["Check out this cool post!", viewModel.postURL],
                        applicationActivities: []
                    )
                    self?.present(vc, animated: true, completion: nil)
                default:
                    break
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
            
        }))
        present(sheet, animated: true, completion: nil)
    }
    
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell) {
        let vc = ProfileViewController(user: User(username: "potus", email: "potus@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PostViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidUpdateLike(_ cell: PostCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: post.id,
            owner: owner) { sucess in
                guard sucess else {
                    print("Failed to like")
                    return
                }
            }
    }
    
}

extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        
        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: post.id,
            owner: owner) { sucess in
                guard sucess else {
                    print("Failed to like")
                    return
                }
            }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        commentBarView.field.becomeFirstResponder()
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        let cellType = viewModels[index]
        
        switch cellType {
        case .post(let viewModel):
            let vc = UIActivityViewController(
                activityItems: ["Check out this cool post!", viewModel.postURL],
                applicationActivities: []
            )
            present(vc, animated: true, completion: nil)
        default:
            break
        }
        
    }
    
    
}

extension PostViewController: PostLikesCollectionViewCellDelegate {
    func postLikesCollectionViewCellLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        let vc = ListViewController(type: .likers(usernames: post.likers))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PostViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("tapped caption")
    }
}

extension PostViewController {
    private func configureCollectionView() {
        let sectionHeight:CGFloat = 300 + view.width
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
                
                // Item
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                
                let postItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                
                let actionsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                let likeCountItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                let captionItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                
                let commentItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                
                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                // Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)
                    ),
                    subitems: [
                        posterItem,
                        postItem,
                        actionsItem,
                        likeCountItem,
                        captionItem,
                        commentItem,
                        timestampItem
                    ])
                // Sections
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                
                return section
            })
        )
        
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(PosterCollectionViewCell.self,
                                forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        
        collectionView.register(PostCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        
        collectionView.register(PostActionsCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier)
        
        collectionView.register(PostLikesCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier)
        
        collectionView.register(PostCaptionCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        
        collectionView.register(PostDateTimeCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier)
        
        collectionView.register(CommentCollectionViewCell.self,
                                forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.collectionView = collectionView
    }
}
