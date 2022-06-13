//
//  PostLikesCollectionViewCell.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 20.05.2022.
//

import UIKit

protocol PostLikesCollectionViewCellDelegate: AnyObject {
    func postLikesCollectionViewCellLikeCount(_ cell: PostLikesCollectionViewCell, index: Int)
}

class PostLikesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostLikesCollectionViewCell"
    weak var delegate: PostLikesCollectionViewCellDelegate?
    
    private var index = 0
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapLabel() {
        delegate?.postLikesCollectionViewCellLikeCount(self, index: index)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: contentView.width-12, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostLikesCollectionViewCellViewModel, index: Int) {
        self.index = index
        let users = viewModel.likers
        label.text = "\(users.count) Likes"
    }
}
