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

}
