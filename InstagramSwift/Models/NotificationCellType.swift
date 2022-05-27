//
//  NotificationCellType.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 27.05.2022.
//

import Foundation

enum NotificationCellType{
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}

