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
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signIn(
        email:String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        
    }
    
    public func signUp(
        email:String,
        username: String,
        password: String,
        profilePicture: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {

    }
}
