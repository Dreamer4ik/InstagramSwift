//
//  NotificationsManager.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 26.05.2022.
//

import Foundation

final class NotificationsManager {
    public static let shared = NotificationsManager()
    
    enum IGType: Int {
        case like = 1
        case comment = 2
        case follow = 3
    }
    
    private init() {}
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void) {
        DatabaseManager.shared.getAllNotifications(completion: completion)
    }
    
    static func newIdentifier() -> String {
        let date = Date()
        let number1 = Int.random(in: 0...10000)
        let number2 = Int.random(in: 0...10000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }
    
    public func create(notification: IGNotification, for username: String) {
        let identifier = notification.identifier
        
        guard let dictionary = notification.asDictionary() else {
            return
        }
        
        DatabaseManager.shared.insertNotification(
            identifier: identifier,
            data: dictionary,
            for: username
        )
    }
}
