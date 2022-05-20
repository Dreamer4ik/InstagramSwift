//
//  HomeViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()
    
    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .purple,
        .systemPink,
        .systemTeal
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemTeal
        
        configureCollectionView()
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func fetchPosts() {
        // mock data
        let postData: [HomeFeedCellType] = [
            .poster(viewModel: PosterCollectionViewCellViewModel(
                username: "dreamer",
                profilePictureURL: URL(string: "https://images.pexels.com/photos/2245436/pexels-photo-2245436.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260")!
            )),
            .post(viewModel: PostCollectionViewCellViewModel(
                postURL: URL(string: "https://images.pexels.com/photos/347141/pexels-photo-347141.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260")!
            )),
            .actions(viewModel: PostActionsCollectionViewCellViewModel(
                isLiked: true
            )),
            .likeCount(viewModel: PostLikesCollectionViewCellViewModel(
                likers: ["potus"]
            )),
            .caption(viewModel: PostCaptionCollectionViewCellViewModel(
                username: "dreamer",
                caption: "First post"
            )),
            .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(
                date: Date()
            ))
        ]
        
        viewModels.append(postData)
        collectionView?.reloadData()
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType{
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifier,
                for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .actions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifier,
                for: indexPath) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifier,
                for: indexPath) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifier,
                for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .timestamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifier,
                for: indexPath) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        }
    }
    
}

extension HomeViewController {
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
        
        self.collectionView = collectionView
    }
}
