//
//  Comment.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 12.06.2022.
//

import Foundation

struct Comment: Codable {
    let username: String
    let comment: String
    let dateString: String
}
