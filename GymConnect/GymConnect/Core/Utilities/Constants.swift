import Foundation

struct Constants {
    // MARK: - App Info
    static let appName = "GymConnect"
    static let bundleId = "com.blakeharris.gymconnect"
    static let appVersion = "1.0.0"
    
    // MARK: - Firebase
    static let firebaseRegion = "us-central1"
    
    // MARK: - Features
    static let maxFitnessGoals = 5
    static let maxFavoriteExercises = 10
    static let maxBioLength = 500
    static let maxDisplayNameLength = 30
    static let spotterRequestExpirationMinutes = 30
    static let autoCheckoutMinutes = 180 // 3 hours
    
    // MARK: - Pagination
    static let defaultPageSize = 20
    static let maxPageSize = 50
    
    // MARK: - Chat
    static let maxMessageLength = 2000
    static let messagesPerPage = 50
    
    // MARK: - Location
    static let defaultSearchRadiusMiles = 25.0
    static let gymProximityThresholdMeters = 200.0
    
    // MARK: - Timing
    static let splashScreenDuration: TimeInterval = 2.5
    static let verificationCodeLength = 6
    static let phoneNumberLength = 10
}

struct AppURLs {
    static let privacyPolicy = "https://gymconnect.app/privacy"
    static let termsOfService = "https://gymconnect.app/terms"
    static let support = "https://gymconnect.app/support"
}

struct NotificationKeys {
    static let userDidSignIn = "userDidSignIn"
    static let userDidSignOut = "userDidSignOut"
    static let didReceiveMessage = "didReceiveMessage"
    static let spotterRequestReceived = "spotterRequestReceived"
}