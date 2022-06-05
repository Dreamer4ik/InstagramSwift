//
//  ProfileViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let user: User
    
    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }
    
    private var collectionView: UICollectionView?
    
    private var headerViewModel: ProfileHeaderViewModel?
    
    private var posts: [Post] = []
    
    // MARK: - Init
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = user.username.capitalized
        tabBarItem.title = "Profile"
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()
        fetchProfileInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func configureNavBar() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(didTapSettings))
        }
    }

    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func fetchProfileInfo() {
        let group = DispatchGroup()
        
        // Fetch posts
        group.enter()
        DatabaseManager.shared.posts(for: user.username) { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let posts):
                self?.posts = posts
            case .failure(_):
                break
            }
        }
        
        // Fetch Profile Header
        var profilePictureUrl: URL?
        var buttonType: ProfileButtonType = .edit
        var followers = 0
        var following = 0
        var posts = 0
        var name: String?
        var bio: String?
        
        // Counts (3)
        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) { result in
            defer {
                group.leave()
            }
            posts = result.posts
            followers = result.followers
            following = result.following
        }
        
        // Bio, name
        group.enter()
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            defer {
                group.leave()
            }
            name = userInfo?.name ?? "name"
            bio = userInfo?.bio ?? "bio"
        }
        
        // Profile picture url
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) { url in
            defer {
                group.leave()
            }
            profilePictureUrl = url
        }
        
        // if profile is not for current user
        if !isCurrentUser {
            //get follow state
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: user.username) { isFollowing in
                defer {
                    group.leave()
                }
                buttonType = .follow(isFollowing: isFollowing)
            }
        }
        
        group.notify(queue: .main) {
            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureUrl: profilePictureUrl,
                followerCount: followers,
                followingCount: following,
                postCount: posts,
                buttonType: buttonType,
                name: name,
                bio: bio
            )
            self.collectionView?.reloadData()
        }
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.countContainerView.delegate = self
        }
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {
        
        guard isCurrentUser else {
            return
        }
        
        let sheet = UIAlertController(title: "Change Picture",
                                      message: "Update your photo to reflect your best self.",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .camera
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        StorageManager.shared.uploadProfilePicture(
            username: user.username,
            data: image.pngData()
        ) { [weak self] success in
            if success {
                self?.headerViewModel = nil
                self?.posts = []
                self?.fetchProfileInfo()
            }
        }
    }
}

extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 18 else {
            return
        }
        collectionView?.setContentOffset(CGPoint(x: 0, y: view.width * 0.7),
                                         animated: true)
    }
    
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            // refetch header info
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapUnfollow(_ containerView: ProfileHeaderCountView) {
        
    } 
}

extension ProfileViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _  -> NSCollectionLayoutSection? in
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(0.33)),
                    subitem: item,
                    count: 3)
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(0.66)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
                ]
                
                return section
            }))
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        collectionView.register(ProfileHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        self.collectionView = collectionView
    }
}
