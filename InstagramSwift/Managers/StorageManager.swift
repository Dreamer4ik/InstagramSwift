//
//  StorageManager.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    public static let shared = StorageManager()
    
    private let storageBucket = Storage.storage().reference()
    
    private init() {}
    
    public func uploadPost(
        data: Data?,
        id: String,
        completion: @escaping(URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storageBucket.child("\(username)/posts/\(id).png")
        
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
 
    public func profilePictureURL(for username: String, completion: @escaping (URL?) -> Void) {
        let path = "\(username)/profile_picture.png"
        
        storageBucket.child(path).downloadURL { url, _ in
            completion(url)
        }
        
    }
    
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            completion(nil)
            return
        }
        
        storageBucket.child(ref).downloadURL { url, _ in
            completion(url)
        }
    }
    
    public func uploadProfilePicture(
        username: String,
        data: Data?,
        completion: @escaping(Bool) -> Void
    ) {
        guard let data = data else {
            return
        }
        storageBucket.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
}
