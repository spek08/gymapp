# GymConnect - iOS App

## Project Overview
GymConnect is a gym-based social networking app for Oklahoma City metro area, connecting gym members for friendship, accountability, and training partnerships.

## Tech Stack
- **Frontend:** SwiftUI (iOS 16+)
- **Backend:** Firebase (Spark free tier)
- **Database:** Cloud Firestore
- **Storage:** Firebase Storage
- **Authentication:** Firebase Auth (Phone + Apple Sign-In)

## Project Structure
```
GymConnect/
├── App/                    # App entry point and configuration
├── Resources/              # Assets, colors, fonts
├── Core/
│   ├── Models/            # Data models (User, Gym, Checkin, etc.)
│   ├── Services/          # Firebase services
│   ├── ViewModels/        # State management
│   └── Utilities/         # Helpers and extensions
├── Features/              # UI screens
│   ├── Splash/
│   ├── Onboarding/
│   ├── Auth/
│   ├── Main/
│   ├── Home/
│   ├── Profile/
│   ├── Gym/
│   ├── Chat/
│   └── Spotter/
├── Components/            # Reusable UI components
└── Navigation/            # Routing
```

## Setup Instructions

### 1. Prerequisites
- Xcode 15+ 
- iOS 16+ device or simulator
- Apple Developer Account
- Firebase account

### 2. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: `gymconnect-okc`
3. Add iOS app with bundle ID: `com.blakeharris.gymconnect`
4. Download `GoogleService-Info.plist`
5. Place in `GymConnect/Resources/`
6. Enable Authentication (Phone + Apple Sign-In)
7. Enable Firestore Database
8. Enable Storage
9. Deploy security rules from `Firebase/` folder

### 3. Xcode Setup
1. Open `GymConnect.xcodeproj`
2. Add Firebase SDK via Swift Package Manager:
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: 10.18.0
   - Select: Analytics, Auth, Firestore, Storage, Messaging
3. Build and run

### 4. Seed Data
Run the following to populate Oklahoma City gyms:
```swift
let gymService = GymService()
try? await gymService.seedOklahomaCityGyms()
```

## Features

### MVP (Week 1-12)
- [x] Phone authentication
- [x] Apple Sign-In
- [x] User profiles
- [x] Gym selection (50+ OKC metro gyms)
- [x] Real-time check-ins
- [x] User discovery
- [x] Direct messaging
- [x] Spotter requests
- [x] Report/Block system

### V2 Features (Future)
- Dating mode toggle
- Stories/photos feed
- Group chats
- Events/challenges
- PR tracking
- Premium subscriptions

## Security
- Firestore security rules implemented
- Phone number verification required
- User blocking and reporting
- Privacy controls (profile visibility)
- Gym-based access controls

## License
Copyright 2024 Blake Harris. All rights reserved.

## Support
For support, email: support@gymconnect.app
