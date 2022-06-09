//
//  Post.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import Foundation

struct Post: Codable {
    let id: String
    let caption: String
    let postedDate: String
    let postUrlString: String
    var likers: [String]
    
    var date: Date {
        return DateFormatter.defaultFormatter.date(from: postedDate) ?? Date()
    }
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        
        return "\(username)/posts/\(id).png"
    }
}
