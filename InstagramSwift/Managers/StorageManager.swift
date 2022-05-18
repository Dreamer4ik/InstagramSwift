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
