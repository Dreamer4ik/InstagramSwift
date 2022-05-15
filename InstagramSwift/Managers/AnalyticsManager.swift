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
    
    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
}
