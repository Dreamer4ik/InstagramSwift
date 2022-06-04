//
//  ProfileHeaderCountView.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 04.06.2022.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapUnfollow(_ containerView: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {
    
    weak var delegate: ProfileHeaderCountViewDelegate?
    
    private var action = ProfileButtonType.edit
    
    // Count Buttons
    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(followerCountButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        addActions()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addActions() {
        followerCountButton.addTarget(self, action: #selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    @objc private func didTapFollowers() {
        delegate?.profileHeaderCountViewDidTapFollowers(self)
    }
    
    @objc private func didTapFollowing() {
        delegate?.profileHeaderCountViewDidTapFollowing(self)
    }
    
    @objc private func didTapPosts() {
        delegate?.profileHeaderCountViewDidTapPosts(self)
    }
    
    @objc private func didTapActionButton() {
        switch action {
        case .edit:
            delegate?.profileHeaderCountViewDidTapEditProfile(self)
        case .follow(let isFollowing):
            if isFollowing {
                // Unfollow; hence tapped follow
                delegate?.profileHeaderCountViewDidTapUnfollow(self)
            }
            else {
                // Follow
                delegate?.profileHeaderCountViewDidTapFollow(self)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width-15)/3
        followerCountButton.frame = CGRect(
            x: 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        
        followingCountButton.frame = CGRect(
            x: followerCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        
        postCountButton.frame = CGRect(
            x: followingCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        
        actionButton.frame = CGRect(
            x: 5,
            y: height-42,
            width: width-10,
            height: 40
        )
    }
    
    func configure(with viewModel: ProfileHeaderCountViewViewModel) {
        followerCountButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        postCountButton.setTitle("\(viewModel.postsCount)\nPosts", for: .normal)
        
        self.action = viewModel.actionType
        
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
            
        case .follow(let isFollowing):
            actionButton.backgroundColor = isFollowing ? .systemBackground : .systemBlue
            actionButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
            actionButton.setTitleColor(isFollowing ? .label : .white, for: .normal)
            
            if isFollowing {
                actionButton.layer.borderWidth = 0.5
                actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
            }
            else {
                actionButton.layer.borderWidth = 0
            }
        }
    }
}