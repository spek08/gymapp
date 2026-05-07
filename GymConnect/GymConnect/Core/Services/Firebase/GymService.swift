import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class GymService {
    private let db = Firestore.firestore()
    
    // MARK: - Gym Queries
    
    func getGyms(near location: CLLocationCoordinate2D, radiusInMiles: Double = 25) async throws -> [Gym] {
        // For MVP, we'll query all active gyms and sort by distance
        // In production, use Firestore geohash or GeoPoint queries
        let snapshot = try await db.collection("gyms")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        let gyms = try snapshot.documents.compactMap { try $0.data(as: Gym.self) }
        
        // Sort by distance
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return gyms.map { gym -> (Gym, Double) in
            let gymLocation = CLLocation(latitude: gym.location.latitude, longitude: gym.location.longitude)
            let distance = userLocation.distance(from: gymLocation) / 1609.34 // Convert to miles
            return (gym, distance)
        }
        .filter { $0.1 <= radiusInMiles }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
    }
    
    func getGym(id: String) async throws -> Gym {
        let document = try await db.collection("gyms").document(id).getDocument()
        
        guard let gym = try? document.data(as: Gym.self) else {
            throw ServiceError.gymNotFound
        }
        
        return gym
    }
    
    func searchGyms(query: String, near location: CLLocationCoordinate2D? = nil) async throws -> [Gym] {
        let snapshot = try await db.collection("gyms")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        let gyms = try snapshot.documents.compactMap { try $0.data(as: Gym.self) }
        
        let lowerQuery = query.lowercased()
        var filtered = gyms.filter { gym in
            gym.name.lowercased().contains(lowerQuery) ||
            gym.city.lowercased().contains(lowerQuery) ||
            gym.neighborhood?.lowercased().contains(lowerQuery) == true
        }
        
        // Sort by distance if location provided
        if let location = location {
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            filtered = filtered.sorted { gym1, gym2 in
                let loc1 = CLLocation(latitude: gym1.location.latitude, longitude: gym1.location.longitude)
                let loc2 = CLLocation(latitude: gym2.location.latitude, longitude: gym2.location.longitude)
                return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
            }
        }
        
        return filtered
    }
    
    func getGymsByType(_ type: Gym.GymType, near location: CLLocationCoordinate2D) async throws -> [Gym] {
        let snapshot = try await db.collection("gyms")
            .whereField("isActive", isEqualTo: true)
            .whereField("gymType", isEqualTo: type.rawValue)
            .getDocuments()
        
        let gyms = try snapshot.documents.compactMap { try $0.data(as: Gym.self) }
        
        // Sort by distance
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return gyms.sorted { gym1, gym2 in
            let loc1 = CLLocation(latitude: gym1.location.latitude, longitude: gym1.location.longitude)
            let loc2 = CLLocation(latitude: gym2.location.latitude, longitude: gym2.location.longitude)
            return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
        }
    }
    
    // MARK: - Gym Stats
    
    func updateGymMemberCount(gymId: String, increment: Int) async throws {
        let gymRef = db.collection("gyms").document(gymId)
        
        try await db.runTransaction { transaction, errorPointer in
            let gymDoc: DocumentSnapshot
            do {
                try gymDoc = transaction.getDocument(gymRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCount = gymDoc.data()?["totalMembers"] as? Int else {
                return nil
            }
            
            transaction.updateData(["totalMembers": oldCount + increment], forDocument: gymRef)
            return nil
        }
    }
    
    func updateActiveCheckins(gymId: String, increment: Int) async throws {
        let gymRef = db.collection("gyms").document(gymId)
        
        try await db.runTransaction { transaction, errorPointer in
            let gymDoc: DocumentSnapshot
            do {
                try gymDoc = transaction.getDocument(gymRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCount = gymDoc.data()?["activeCheckins"] as? Int else {
                return nil
            }
            
            transaction.updateData(["activeCheckins": max(0, oldCount + increment)], forDocument: gymRef)
            return nil
        }
    }
}

// MARK: - Seed Data
extension GymService {
    func seedOklahomaCityGyms() async throws {
        let gyms = GymSeedData.oklahomaCityGyms
        
        for gym in gyms {
            let docRef = db.collection("gyms").document(gym.slug)
            let doc = try? await docRef.getDocument()
            
            if doc?.exists != true {
                try docRef.setData(from: gym)
            }
        }
    }
}

struct GymSeedData {
    static let oklahomaCityGyms: [Gym] = [
        // Oklahoma City - Major Chains
        Gym(name: "Gold's Gym - Bricktown", slug: "golds-gym-bricktown", address: "100 E California Ave", city: "Oklahoma City", zipCode: "73104", location: GeoPoint(latitude: 35.4654, longitude: -97.5148), neighborhood: "Bricktown", phone: "(405) 555-0100", gymType: .commercialChain, amenities: ["weights", "cardio", "pool", "sauna", "classes", "parking"]),
        
        Gym(name: "Gold's Gym - NW Expressway", slug: "golds-gym-nw-expressway", address: "4200 W Memorial Rd", city: "Oklahoma City", zipCode: "73134", location: GeoPoint(latitude: 35.6097, longitude: -97.5989), neighborhood: "Quail Springs", phone: "(405) 555-0101", gymType: .commercialChain, amenities: ["weights", "cardio", "pool", "classes", "parking"]),
        
        Gym(name: "Planet Fitness - OKC Downtown", slug: "planet-fitness-okc-downtown", address: "325 N Walker Ave", city: "Oklahoma City", zipCode: "73102", location: GeoPoint(latitude: 35.4712, longitude: -97.5215), neighborhood: "Downtown", phone: "(405) 555-0102", gymType: .commercialChain, amenities: ["weights", "cardio", "24_hour"]),
        
        Gym(name: "Planet Fitness - Moore", slug: "planet-fitness-moore", address: "2200 S Service Rd", city: "Moore", zipCode: "73160", location: GeoPoint(latitude: 35.3094, longitude: -97.4943), phone: "(405) 555-0103", gymType: .commercialChain, amenities: ["weights", "cardio", "24_hour"]),
        
        Gym(name: "LA Fitness - Memorial Road", slug: "la-fitness-memorial", address: "13420 N Pennsylvania Ave", city: "Oklahoma City", zipCode: "73120", location: GeoPoint(latitude: 35.6072, longitude: -97.5495), neighborhood: "Quail Springs", phone: "(405) 555-0104", gymType: .commercialChain, amenities: ["weights", "cardio", "pool", "basketball", "classes"]),
        
        // CrossFit
        Gym(name: "Top Tier Fitness - CrossFit", slug: "top-tier-crossfit", address: "1234 NW 10th St", city: "Oklahoma City", zipCode: "73106", location: GeoPoint(latitude: 35.4789, longitude: -97.5345), neighborhood: "Midtown", phone: "(405) 555-0200", gymType: .crossfit, amenities: ["weights", "classes", "personal_training"]),
        
        Gym(name: "Okie CrossFit", slug: "okie-crossfit", address: "5678 S Broadway", city: "Edmond", zipCode: "73013", location: GeoPoint(latitude: 35.6528, longitude: -97.4781), phone: "(405) 555-0201", gymType: .crossfit, amenities: ["weights", "classes", "personal_training"]),
        
        // Powerlifting
        Gym(name: "Iron Haven Gym", slug: "iron-haven-gym", address: "8901 NE 23rd St", city: "Oklahoma City", zipCode: "73141", location: GeoPoint(latitude: 35.4932, longitude: -97.4789), neighborhood: "Northeast OKC", phone: "(405) 555-0300", gymType: .powerlifting, amenities: ["weights", "personal_training"]),
        
        // MMA/Boxing
        Gym(name: "Bricktown Boxing", slug: "bricktown-boxing", address: "200 E Sheridan Ave", city: "Oklahoma City", zipCode: "73104", location: GeoPoint(latitude: 35.4667, longitude: -97.5100), neighborhood: "Bricktown", phone: "(405) 555-0400", gymType: .mmaBoxing, amenities: ["classes", "personal_training"]),
        
        // Yoga/Pilates
        Gym(name: "Core Fitness Studio", slug: "core-fitness-studio", address: "1500 Classen Blvd", city: "Oklahoma City", zipCode: "73106", location: GeoPoint(latitude: 35.4821, longitude: -97.5267), neighborhood: "Midtown", phone: "(405) 555-0500", gymType: .yogaPilates, amenities: ["classes", "parking"]),
        
        // Boutique
        Gym(name: "Orangetheory Fitness - OKC", slug: "orangetheory-okc", address: "3000 W Memorial Rd", city: "Oklahoma City", zipCode: "73120", location: GeoPoint(latitude: 35.6098, longitude: -97.5667), neighborhood: "Quail Springs", phone: "(405) 555-0600", gymType: .boutiqueFitness, amenities: ["classes", "parking"]),
        
        Gym(name: "F45 Training - Norman", slug: "f45-training-norman", address: "1200 E Main St", city: "Norman", zipCode: "73071", location: GeoPoint(latitude: 35.2189, longitude: -97.4256), phone: "(405) 555-0601", gymType: .boutiqueFitness, amenities: ["classes"]),
        
        // University
        Gym(name: "OU Recreation Center", slug: "ou-rec-center", address: "1401 Asp Ave", city: "Norman", zipCode: "73019", location: GeoPoint(latitude: 35.2089, longitude: -97.4456), neighborhood: "OU Campus", phone: "(405) 555-0700", gymType: .university, amenities: ["weights", "cardio", "pool", "classes"]),
        
        // Local Gyms
        Gym(name: "The Fitness Firm", slug: "the-fitness-firm", address: "4500 S May Ave", city: "Oklahoma City", zipCode: "73119", location: GeoPoint(latitude: 35.4200, longitude: -97.5656), phone: "(405) 555-0800", gymType: .localGym, amenities: ["weights", "cardio", "classes"]),
        
        Gym(name: "Threshold Fitness", slug: "threshold-fitness", address: "789 Council Rd", city: "Oklahoma City", zipCode: "73127", location: GeoPoint(latitude: 35.4656, longitude: -97.6567), phone: "(405) 555-0801", gymType: .localGym, amenities: ["weights", "cardio", "classes", "personal_training"])
    ]
}