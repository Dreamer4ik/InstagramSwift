//
//  ProfileHeaderCollectionReusableView.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 31.05.2022.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    public let countContainerView = ProfileHeaderCountView()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "iOS Developer\nThis my profile bio!"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countContainerView)
        addSubview(imageView)
        addSubview(bioLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = width/3.5
        imageView.frame = CGRect(
            x: 5,
            y: 5,
            width: imageSize,
            height: imageSize
        )
        imageView.layer.cornerRadius = imageSize/2
        
        countContainerView.frame = CGRect(
            x: imageView.right + 5,
            y: 3,
            width: width - imageView.right-10,
            height: imageSize
        )
        let bioSize = bioLabel.sizeThatFits(
            bounds.size
        )
        bioLabel.frame = CGRect(
            x: 5,
            y: imageView.bottom + 10,
            width: width - 10,
            height: bioSize.height + 50
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bioLabel.text = nil
    }
    
    public func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? "iOS Developer"
        bioLabel.text = text
        // Container
        let containerViewModel = ProfileHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postsCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }
    
}
