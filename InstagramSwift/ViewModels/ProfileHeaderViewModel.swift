//
//  ProfileHeaderViewModel.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 31.05.2022.
//

import Foundation

enum ProfileButtonType{
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePictureUrl: URL?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let name: String?
    let bio: String?
}
