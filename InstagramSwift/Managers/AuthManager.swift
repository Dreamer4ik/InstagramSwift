//
//  AuthManager.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    public static let shared = AuthManager()
    
    let auth = Auth.auth()
    
    private init() {}
    
    
}
