//
//  AnalyticsManager.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    public static let shared = AnalyticsManager()
    
    private init() {}
    
    enum FeedInteraction: String {
        case like
        case comment
        case share
        case reported
        case doubleTapToLike
    }
    
    func logFeedInteraction(_ type: FeedInteraction) {
        Analytics.logEvent("feedback_interaction",
                           parameters: ["type":type.rawValue.lowercased()])
    }
}
