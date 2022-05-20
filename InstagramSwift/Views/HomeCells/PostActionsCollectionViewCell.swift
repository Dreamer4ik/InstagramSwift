//
//  PostActionsCollectionViewCell.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 20.05.2022.
//

import UIKit

class PostActionsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostActionsCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostActionsCollectionViewCellViewModel) {
        
    }
}
