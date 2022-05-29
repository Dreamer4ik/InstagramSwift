//
//  LikeNotificationTableViewCell.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 26.05.2022.
//

import UIKit

protocol LikeNotificationTableViewCellDelegate: AnyObject {
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell,
                                       didTapPostWith viewModel: LikeNotificationCellViewModel)
}

class LikeNotificationTableViewCell: UITableViewCell {
    static let identifier = "LikeNotificationTableViewCell"
    
    weak var delegate: LikeNotificationTableViewCellDelegate?
    
    private var viewModel: LikeNotificationCellViewModel?
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        clipsToBounds = true
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(label)
        contentView.addSubview(postImageView)
        
        postImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapPost() {
        guard let vm = viewModel else {
            return
        }
        delegate?.likeNotificationTableViewCell(self, didTapPostWith: vm)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        
        profilePictureImageView.layer.cornerRadius = imageSize/2
        
        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(
            x: contentView.width - postSize - 10,
            y: 3,
            width: postSize,
            height: postSize
        )
        
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profilePictureImageView.right - 25 - postSize,
                height: contentView.height
            )
        )
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        postImageView.image = nil
    }
    
    public func configure(with viewModel: LikeNotificationCellViewModel) {
        self.viewModel = viewModel
        label.text = viewModel.username + " liked your post."
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
        postImageView.sd_setImage(with: viewModel.postURL, completed: nil)
    }
}