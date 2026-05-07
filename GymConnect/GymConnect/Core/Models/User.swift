import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    
    // Profile Basics
    var displayName: String
    var email: String?
    var phoneNumber: String
    var bio: String
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    
    // Fitness Profile
    var experienceLevel: ExperienceLevel
    var fitnessGoals: [FitnessGoal]
    var favoriteExercises: [String]
    var workoutSchedule: WorkoutSchedule
    
    // Gym Association
    var primaryGymId: String?
    var secondaryGymIds: [String]
    var gymJoinedAt: Date?
    
    // Status
    var isOnline: Bool
    var lastActive: Date?
    var currentCheckinId: String?
    
    // Verification
    var isVerified: Bool
    var verificationMethod: VerificationMethod
    var verificationPhotoUrl: String?
    var verificationRequestedAt: Date?
    
    // Privacy
    var privacySettings: PrivacySettings
    
    // Preferences
    var notificationSettings: NotificationSettings
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var onboardingCompleted: Bool
    var fcmToken: String?
    var platform: String
    var appVersion: String
    
    enum ExperienceLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case elite = "Elite"
        
        var color: String {
            switch self {
            case .beginner: return "SuccessGreen"
            case .intermediate: return "PrimaryBlue"
            case .advanced: return "EnergyOrange"
            case .elite: return "AlertRed"
            }
        }
        
        var description: String {
            switch self {
            case .beginner: return "New to training"
            case .intermediate: return "1-2 years experience"
            case .advanced: return "3+ years experience"
            case .elite: return "Competitive athlete"
            }
        }
    }
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case loseWeight = "Lose Weight"
        case buildMuscle = "Build Muscle"
        case increaseStrength = "Increase Strength"
        case improveEndurance = "Improve Endurance"
        case flexibility = "Flexibility"
        case generalFitness = "General Fitness"
        
        var icon: String {
            switch self {
            case .loseWeight: return "flame.fill"
            case .buildMuscle: return "figure.arms.open"
            case .increaseStrength: return "dumbbell.fill"
            case .improveEndurance: return "figure.run"
            case .flexibility: return "figure.mind.and.body"
            case .generalFitness: return "heart.fill"
            }
        }
    }
    
    enum VerificationMethod: String, Codable {
        case photo = "photo"
        case gymStaff = "gym_staff"
        case none = "none"
    }
    
    init(id: String? = nil,
         displayName: String = "",
         email: String? = nil,
         phoneNumber: String = "",
         bio: String = "",
         profilePhotoUrl: String? = nil,
         experienceLevel: ExperienceLevel = .beginner,
         fitnessGoals: [FitnessGoal] = [],
         createdAt: Date = Date(),
         onboardingCompleted: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.phoneNumber = phoneNumber
        self.bio = bio
        self.profilePhotoUrl = profilePhotoUrl
        self.experienceLevel = experienceLevel
        self.fitnessGoals = fitnessGoals
        self.favoriteExercises = []
        self.workoutSchedule = WorkoutSchedule()
        self.isOnline = false
        self.isVerified = false
        self.verificationMethod = .none
        self.privacySettings = PrivacySettings()
        self.notificationSettings = NotificationSettings()
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.onboardingCompleted = onboardingCompleted
        self.platform = "ios"
        self.appVersion = "1.0.0"
        self.secondaryGymIds = []
    }
}

struct PrivacySettings: Codable {
    var profileVisible: Visibility
    var showOnlineStatus: Bool
    var showLastActive: Bool
    var allowMessages: Visibility
    var allowSpotRequests: Visibility
    
    enum Visibility: String, Codable {
        case everyone = "Everyone"
        case gymOnly = "Gym Members Only"
        case friendsOnly = "Friends Only"
    }
    
    init(profileVisible: Visibility = .gymOnly,
         showOnlineStatus: Bool = true,
         showLastActive: Bool = true,
         allowMessages: Visibility = .gymOnly,
         allowSpotRequests: Visibility = .gymOnly) {
        self.profileVisible = profileVisible
        self.showOnlineStatus = showOnlineStatus
        self.showLastActive = showLastActive
        self.allowMessages = allowMessages
        self.allowSpotRequests = allowSpotRequests
    }
}

struct NotificationSettings: Codable {
    var newMessages: Bool
    var spotRequests: Bool
    var gymAnnouncements: Bool
    var marketingEmails: Bool
    
    init(newMessages: Bool = true,
         spotRequests: Bool = true,
         gymAnnouncements: Bool = true,
         marketingEmails: Bool = false) {
        self.newMessages = newMessages
        self.spotRequests = spotRequests
        self.gymAnnouncements = gymAnnouncements
        self.marketingEmails = marketingEmails
    }
}

struct WorkoutSchedule: Codable {
    var monday: [TimeSlot]
    var tuesday: [TimeSlot]
    var wednesday: [TimeSlot]
    var thursday: [TimeSlot]
    var friday: [TimeSlot]
    var saturday: [TimeSlot]
    var sunday: [TimeSlot]
    
    struct TimeSlot: Codable, Equatable {
        var start: String
        var end: String
        
        init(start: String, end: String) {
            self.start = start
            self.end = end
        }
    }
    
    init(monday: [TimeSlot] = [],
         tuesday: [TimeSlot] = [],
         wednesday: [TimeSlot] = [],
         thursday: [TimeSlot] = [],
         friday: [TimeSlot] = [],
         saturday: [TimeSlot] = [],
         sunday: [TimeSlot] = []) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}

// MARK: - Sample Data for Previews
extension User {
    static var sample: User {
        User(
            id: "sample_user_1",
            displayName: "Alex Johnson",
            email: "alex@example.com",
            phoneNumber: "+14051234567",
            bio: "Looking for a consistent lifting partner! Training for my first powerlifting meet.",
            profilePhotoUrl: nil,
            experienceLevel: .intermediate,
            fitnessGoals: [.increaseStrength, .buildMuscle],
            createdAt: Date(),
            onboardingCompleted: true
        )
    }
}