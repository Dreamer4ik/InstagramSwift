//
//  DatabaseManager.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {

    public static let shared = DatabaseManager()

    let database = Firestore.firestore()
    
    private init() {}

}
