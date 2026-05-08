import SwiftUI

// Route enum is defined in AppRouter.swift
// This file can be used for route-specific extensions and helpers

extension Route {
    var title: String {
        switch self {
        case .onboarding:
            return "Welcome"
        case .login:
            return "Sign In"
        case .main:
            return "Home"
        case .gymSelector:
            return "Select Gym"
        case .userProfile:
            return "Profile"
        case .chat:
            return "Chat"
        case .settings:
            return "Settings"
        case .editProfile:
            return "Edit Profile"
        case .privacySettings:
            return "Privacy"
        case .notificationSettings:
            return "Notifications"
        case .blockedUsers:
            return "Blocked Users"
        case .help:
            return "Help"
        }
    }
    
    var shouldHideTabBar: Bool {
        switch self {
        case .chat, .userProfile, .settings, .editProfile, .privacySettings, .notificationSettings, .blockedUsers, .help:
            return true
        default:
            return false
        }
    }
}