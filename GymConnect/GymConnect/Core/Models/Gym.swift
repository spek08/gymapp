import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct Gym: Identifiable, Codable {
    @DocumentID var id: String?
    
    // Basic Info
    var name: String
    var slug: String
    var description: String?
    
    // Location
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var location: GeoPoint
    var neighborhood: String?
    
    // Contact
    var phone: String?
    var website: String?
    var email: String?
    
    // Details
    var gymType: GymType
    var amenities: [String]
    var hours: GymHours
    
    // Media
    var photos: [String]
    var logoUrl: String?
    
    // Stats
    var totalMembers: Int
    var activeCheckins: Int
    var averageRating: Double?
    
    // Verification
    var isVerified: Bool
    var verificationMethod: VerificationMethod
    
    // Discovery
    var isActive: Bool
    var featured: Bool
    
    var createdAt: Date
    var updatedAt: Date
    
    enum GymType: String, Codable, CaseIterable {
        case commercialChain = "Commercial Chain"
        case localGym = "Local Gym"
        case crossfit = "CrossFit"
        case yogaPilates = "Yoga & Pilates"
        case mmaBoxing = "MMA & Boxing"
        case powerlifting = "Powerlifting"
        case boutiqueFitness = "Boutique Fitness"
        case university = "University"
        case rockClimbing = "Rock Climbing"
        case swimmingAquatic = "Swimming & Aquatic"
        
        var icon: String {
            switch self {
            case .commercialChain: return "building.2"
            case .localGym: return "house"
            case .crossfit: return "figure.strengthtraining.traditional"
            case .yogaPilates: return "figure.mind.and.body"
            case .mmaBoxing: return "figure.boxing"
            case .powerlifting: return "dumbbell.fill"
            case .boutiqueFitness: return "sparkles"
            case .university: return "graduationcap"
            case .rockClimbing: return "figure.climbing"
            case .swimmingAquatic: return "figure.pool.swim"
            }
        }
    }
    
    enum VerificationMethod: String, Codable {
        case manual = "manual"
        case ownerClaimed = "owner_claimed"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
    
    init(id: String? = nil,
         name: String,
         slug: String,
         description: String? = nil,
         address: String,
         city: String,
         state: String = "OK",
         zipCode: String,
         location: GeoPoint,
         neighborhood: String? = nil,
         phone: String? = nil,
         website: String? = nil,
         email: String? = nil,
         gymType: GymType,
         amenities: [String] = [],
         photos: [String] = [],
         isVerified: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.location = location
        self.neighborhood = neighborhood
        self.phone = phone
        self.website = website
        self.email = email
        self.gymType = gymType
        self.amenities = amenities
        self.hours = GymHours()
        self.photos = photos
        self.totalMembers = 0
        self.activeCheckins = 0
        self.isVerified = isVerified
        self.verificationMethod = .manual
        self.isActive = true
        self.featured = false
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}

struct GymHours: Codable {
    struct DayHours: Codable {
        var open: String
        var close: String
        var isOpen: Bool
        
        init(open: String = "06:00", close: String = "22:00", isOpen: Bool = true) {
            self.open = open
            self.close = close
            self.isOpen = isOpen
        }
    }
    
    var monday: DayHours
    var tuesday: DayHours
    var wednesday: DayHours
    var thursday: DayHours
    var friday: DayHours
    var saturday: DayHours
    var sunday: DayHours
    
    init(monday: DayHours = DayHours(),
         tuesday: DayHours = DayHours(),
         wednesday: DayHours = DayHours(),
         thursday: DayHours = DayHours(),
         friday: DayHours = DayHours(),
         saturday: DayHours = DayHours(),
         sunday: DayHours = DayHours()) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
    
    func hours(for weekday: Int) -> DayHours {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return monday
        }
    }
}

// MARK: - Sample Data for Previews
extension Gym {
    static var sample: Gym {
        Gym(
            id: "sample_gym_1",
            name: "Gold's Gym - Bricktown",
            slug: "golds-gym-bricktown",
            description: "The mecca of bodybuilding in OKC",
            address: "100 E California Ave",
            city: "Oklahoma City",
            zipCode: "73104",
            location: GeoPoint(latitude: 35.4654, longitude: -97.5148),
            neighborhood: "Bricktown",
            phone: "(405) 555-0123",
            gymType: .commercialChain,
            amenities: ["weights", "cardio", "pool", "sauna", "classes"],
            isVerified: true
        )
    }
}