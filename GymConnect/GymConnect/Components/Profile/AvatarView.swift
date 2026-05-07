import SwiftUI
import Kingfisher

struct AvatarView: View {
    let imageUrl: String?
    let size: CGFloat
    let isOnline: Bool
    let showBorder: Bool
    
    init(
        imageUrl: String?,
        size: CGFloat = 60,
        isOnline: Bool = false,
        showBorder: Bool = true
    ) {
        self.imageUrl = imageUrl
        self.size = size
        self.isOnline = isOnline
        self.showBorder = showBorder
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                placeholder
            }
            
            if isOnline {
                Circle()
                    .fill(Color("SuccessGreen"))
                    .frame(width: size * 0.25, height: size * 0.25)
                    .overlay(
                        Circle()
                            .stroke(Color("Background"), lineWidth: 2)
                    )
                    .offset(x: -2, y: -2)
            }
        }
        .overlay(
            Circle()
                .stroke(showBorder ? Color("Surface") : Color.clear, lineWidth: 2)
        )
    }
    
    private var placeholder: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .padding(size * 0.25)
            .frame(width: size, height: size)
            .background(Color("SurfaceElevated"))
            .foregroundColor(Color("TextTertiary"))
            .clipShape(Circle())
    }
}

struct OnlineIndicator: View {
    let isOnline: Bool
    let size: CGFloat
    
    init(isOnline: Bool, size: CGFloat = 8) {
        self.isOnline = isOnline
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(isOnline ? Color("SuccessGreen") : Color("TextTertiary"))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color("Background"), lineWidth: size * 0.15)
            )
    }
}

struct ProfileHeader: View {
    let user: User
    let isCurrentUser: Bool
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Cover photo area
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color("Surface"))
                    .frame(height: 120)
                
                // Avatar overlapping cover
                AvatarView(
                    imageUrl: user.profilePhotoUrl,
                    size: 100,
                    isOnline: user.isOnline
                )
                .offset(x: 20, y: 50)
            }
            .frame(height: 170)
            
            // User info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color("PrimaryBlue"))
                            }
                        }
                        
                        if let gymJoinedAt = user.gymJoinedAt {
                            Text("Member since \(gymJoinedAt.formatted(.dateTime.month().year()))")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    
                    Spacer()
                    
                    if isCurrentUser {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("PrimaryBlue"))
                                .frame(width: 44, height: 44)
                                .background(Color("PrimaryBlue").opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                
                ExperienceBadge(level: user.experienceLevel)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.body)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color("Surface"))
        .cornerRadius(16)
    }
}

// MARK: - Previews
#Preview("Profile Components") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            AvatarView(imageUrl: nil, size: 60, isOnline: true)
            AvatarView(imageUrl: nil, size: 60, isOnline: false)
            AvatarView(imageUrl: nil, size: 80, isOnline: true)
        }
        
        ProfileHeader(user: .sample, isCurrentUser: true, onEdit: {})
    }
    .padding()
    .background(Color("Background"))
}