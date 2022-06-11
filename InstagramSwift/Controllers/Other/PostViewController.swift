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
    
    private var viewModels: [HomeFeedCellType] = []
    
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
        fetchPost()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
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
        
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
            guard let postURL = URL(string: model.postUrlString),
                  let profilePictureURL = profilePictureURL else {
                return
            }
            
            let postData: [HomeFeedCellType] = [
                .poster(viewModel: PosterCollectionViewCellViewModel(
                    username: username,
                    profilePictureURL: profilePictureURL
                )),
                .post(viewModel: PostCollectionViewCellViewModel(
                    postURL: postURL
                )),
                .actions(viewModel: PostActionsCollectionViewCellViewModel(
                    isLiked: false
                )),
                .likeCount(viewModel: PostLikesCollectionViewCellViewModel(
                    likers: []
                )),
                .caption(viewModel: PostCaptionCollectionViewCellViewModel(
                    username: username,
                    caption: model.caption
                )),
                .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(
                    date: DateFormatter.defaultFormatter.date(from: model.postedDate) ?? Date()
                ))
            ]
            
            self?.viewModels = postData
            completion(true)
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
            cell.configure(with: viewModel)
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
            cell.configure(with: viewModel)
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
    func postCollectionViewCellDidUpdateLike(_ cell: PostCollectionViewCell) {
        print("double tap")
    }
    
}

extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        // Call DB to update like state
        print("Did double Tap to Like")
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        //        let vc = PostViewController()
        //        vc.title = "Post"
        //        navigationController?.pushViewController(vc, animated: true)
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
    func postLikesCollectionViewCellLikeCount(_ cell: PostLikesCollectionViewCell) {
        let vc = ListViewController(type: .likers(usernames: []))
        vc.title = "Liked by"
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
        let sectionHeight:CGFloat = 240 + view.width
        
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
        
        self.collectionView = collectionView
    }
}
