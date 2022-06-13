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
    
    private let database = Firestore.firestore()
    
    private init() {}
    
    public func findUsers(with usernamePrefix: String, completion: @escaping ([User]) -> Void) {
        let ref = database.collection("users")
        
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({  User(with: $0.data()) })
                    , error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            
            completion(subset)
        }
    }
    
    public func posts(for username: String,  completion: @escaping (Result<[Post], Error>) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
        ref.getDocuments { snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }).sorted(by: {
                return $0.date > $1.date
            }),
            error == nil else {
                return
            }
            
            completion(.success(posts))
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({  User(with: $0.data()) })
                    , error == nil else {
                completion(nil)
                return
            }
            
            let user = users.first(where: {
                $0.email == email
            })
            completion(user)
        }
    }
    
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({  User(with: $0.data()) })
                    , error == nil else {
                completion(nil)
                return
            }
            
            let user = users.first(where: {
                $0.username == username
            })
            completion(user)
        }
    }
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let ref = database.collection("users")
        
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({  User(with: $0.data()) })
                    , error == nil else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()
            
            users.forEach({ user in
                group.enter()
                let username = user.username
                let postRef = self.database.collection("users/\(username)/posts")
                postRef.getDocuments { snapshot, error in
                    defer {
                        group.leave()
                    }
                    guard let posts = snapshot?.documents.compactMap({  Post(with: $0.data()) })
                            , error == nil else {
                        completion([])
                        return
                    }
                    aggregatePosts.append(contentsOf: posts.compactMap({
                        (post: $0, user: user)
                    }))
                }
            })
            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    
    public func getAllNotifications(completion: @escaping ([IGNotification]) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                IGNotification(with: $0.data())
            }),
                  error == nil else {
                completion([])
                return
            }
            
            completion(notifications)
        }
    }
    
    public func insertNotification(identifier: String, data: [String:Any], for username: String) {
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifier)
        ref.setData(data)
    }
    
    public func getPost(with identifier: String, from username: String, completion: @escaping (Post?) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
            .document(identifier)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            
            completion(Post(with: data))
        }
    }
   
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    public func updateRelationship(state: RelationshipState, for targetUsername: String, completion: (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
       
        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("following")
        
        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")
        
        switch state {
        case .follow:
            // Add follower for currentUser following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])
            completion(true)
        case .unfollow:
            // Remove follower for requester following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).delete()
            completion(true)
        }
    }
    
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userRef = database.collection("users")
            .document(username)
        
        var followers = 0
        var following = 0
        var posts = 0
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        userRef.collection("posts").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }
        
        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }
        
        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }
        
        group.notify(queue: .global()) {
            let result = (
                followers: followers,
                following: following,
                posts: posts
            )
            completion(result)
        }
    }
    
    public func isFollowing(targetUsername: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        let ref = database.collection("users")
            .document(targetUsername)
            .collection("followers")
            .document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // Following
            completion(true)
        }
    }
    
    public func followers(for username: String, completion: @escaping ([String]) -> Void) {
   
        let ref = database.collection("users")
            .document(username)
            .collection("followers")
        
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    /// Gets users that the username follows
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("following")
        
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    // MARK: - User Info
    public func getUserInfo(username: String, completion: @escaping (UserInfo?) -> Void) {
        
        let ref = database.collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let userInfo = UserInfo(with: data),
                  error == nil else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    public func setUserInfo(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username"),
              let data = userInfo.asDictionary() else {
            completion(false)
            return
        }
        let ref = database.collection("users")
            .document(currentUsername)
            .collection("information")
            .document("basic")
        
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Comment
    
    public func createComments(comment:Comment, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...10000))"
        
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
            .document(newIdentifier)
        
        guard let data = comment.asDictionary() else {
            return
        }
        
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func getComments(postID: String, owner: String, completion: @escaping ([Comment]) -> Void) {
        
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
        
        ref.getDocuments { snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }), error == nil else {
                completion([])
                return
            }
            completion(comments)
        }
    }
    
    // MARK: - Like
    
    enum LikeState{
        case like, unlike
    }
    
    public func updateLikeState(state: LikeState, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
        
        getPost(with: postID, from: owner) { post in
            guard var post = post else {
                completion(false)
                return
            }

            switch state {
            case .like:
                if !post.likers.contains(currentUsername) {
                    post.likers.append(currentUsername)
                }
            case .unlike:
                post.likers.removeAll(where: {
                    $0 == currentUsername
                })
            }
            
            guard let data = post.asDictionary() else {
                completion(false)
                return
            }
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
