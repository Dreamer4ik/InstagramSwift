//
//  CommentBarView.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 12.06.2022.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String)
}

final class CommentBarView: UIView, UITextFieldDelegate {
//    static let identifier = "CommentCollectionViewCell"
    weak var delegate: CommentBarViewDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    let field: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .secondarySystemBackground
        return field
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(field)
        addSubview(button)
        field.delegate = self
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        backgroundColor = .tertiarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapComment() {
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        delegate?.commentBarViewDidTapDone(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.sizeToFit()
        button.frame = CGRect(
            x: width-button.width-4-2,
            y: (height-button.height)/2,
            width: button.width+4,
            height: button.height
        )
        
        field.frame = CGRect(
            x: 2,
            y: (height - 50)/2,
            width: width-button.width-12,
            height: 50
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapComment()
        return true
    }
}
