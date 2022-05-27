//
//  NotificationCellViewModels.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 27.05.2022.
//

import Foundation

struct LikeNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
}

struct FollowNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let isCurrentUserFollowing: Bool
}

struct CommentNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
}
