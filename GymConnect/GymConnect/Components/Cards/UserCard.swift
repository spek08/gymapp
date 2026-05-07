import SwiftUI
import Kingfisher

struct UserCard: View {
    let user: User
    let onMessage: () -> Void
    let onSpotRequest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo section
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color("Surface"))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .foregroundColor(Color("TextTertiary"))
                    )
                
                if let photoUrl = user.profilePhotoUrl, let url = URL(string: photoUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .frame(height: 280)
            .overlay(
                // Online status badge
                HStack {
                    if user.isOnline {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color("SuccessGreen"))
                                .frame(width: 8, height: 8)
                            Text("At gym now")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                    }
                    Spacer()
                    
                    // Verified badge
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("PrimaryBlue"))
                            .font(.title3)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                }
                .padding(12),
                alignment: .topLeading
            )
            
            // User info section
            VStack(alignment: .leading, spacing: 10) {
                // Name and experience
                HStack {
                    Text(user.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    ExperienceBadge(level: user.experienceLevel)
                }
                
                // Bio
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(2)
                }
                
                // Goals
                if !user.fitnessGoals.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(user.fitnessGoals.prefix(3), id: \.self) { goal in
                            GoalTag(goal: goal)
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onMessage) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryBlue"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("PrimaryBlue").opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: onSpotRequest) {
                        HStack {
                            Image(systemName: "hands.sparkles.fill")
                            Text("Spot")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("EnergyOrange"))
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .background(Color("Surface"))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct GymCard: View {
    let gym: Gym
    let distance: Double?
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color("SurfaceElevated"))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: gym.gymType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color("PrimaryBlue"))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(1)
                    
                    Text(gym.address)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Label("\(gym.activeCheckins)", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(Color("SuccessGreen"))
                        
                        if let distance = distance {
                            Label(String(format: "%.1f mi", distance), systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(Color("TextTertiary"))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("TextTertiary"))
            }
            .padding(16)
            .background(Color("Surface"))
            .cornerRadius(12)
        }
    }
}

struct ChatPreviewCard: View {
    let chat: Chat
    let otherUser: User?
    let currentUserId: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AvatarView(
                imageUrl: otherUser?.profilePhotoUrl,
                size: 56,
                isOnline: otherUser?.isOnline ?? false
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.displayName ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    if let timestamp = chat.lastMessage?.timestamp {
                        Text(timestamp.timeAgo())
                            .font(.caption)
                            .foregroundColor(Color("TextTertiary"))
                    }
                }
                
                HStack {
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage.text)
                            .font(.subheadline)
                            .foregroundColor(lastMessage.read ? Color("TextSecondary") : Color("TextPrimary"))
                            .lineLimit(1)
                            .fontWeight(lastMessage.read ? .regular : .semibold)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(Color("TextTertiary"))
                            .italic()
                    }
                    
                    Spacer()
                    
                    if let lastMessage = chat.lastMessage,
                       !lastMessage.read && lastMessage.senderId != currentUserId {
                        Circle()
                            .fill(Color("EnergyOrange"))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding(12)
        .background(Color("Surface"))
        .cornerRadius(12)
    }
}

struct SpotterRequestCard: View {
    let request: SpotterRequest
    let requester: User?
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AvatarView(
                    imageUrl: requester?.profilePhotoUrl,
                    size: 48,
                    isOnline: requester?.isOnline ?? false
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(requester?.displayName ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Needs a spot • \(request.createdAt.timeAgo())")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                StatusBadge(status: request.status)
            }
            
            if let exercise = request.exercise {
                Label(exercise, systemImage: "dumbbell.fill")
                    .font(.subheadline)
                    .foregroundColor(Color("EnergyOrange"))
            }
            
            if let message = request.message, !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(2)
            }
            
            if request.isActive {
                HStack {
                    Label("Expires in \(request.expiresAt.timeRemaining())", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(Color("AlertRed"))
                    
                    Spacer()
                    
                    Button(action: onAccept) {
                        Text("Accept Request")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("SuccessGreen"))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color("Surface"))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views
struct ExperienceBadge: View {
    let level: User.ExperienceLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(level.color))
                .frame(width: 6, height: 6)
            Text(level.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(level.color).opacity(0.15))
        .foregroundColor(Color(level.color))
        .cornerRadius(12)
    }
}

struct GoalTag: View {
    let goal: User.FitnessGoal
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: goal.icon)
                .font(.caption2)
            Text(goal.rawValue)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color("SurfaceElevated"))
        .foregroundColor(Color("TextPrimary"))
        .cornerRadius(20)
    }
}

struct StatusBadge: View {
    let status: SpotterRequest.Status
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusText: String {
        switch status {
        case .active: return "Active"
        case .accepted: return "Accepted"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .expired: return "Expired"
        case .declined: return "Declined"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .active: return Color("EnergyOrange")
        case .accepted: return Color("PrimaryBlue")
        case .completed: return Color("SuccessGreen")
        case .cancelled, .expired, .declined: return Color("TextTertiary")
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                    y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + lineHeight
        }
    }
}

// MARK: - Previews
#Preview("Cards") {
    ScrollView {
        VStack(spacing: 16) {
            UserCard(user: .sample, onMessage: {}, onSpotRequest: {})
            GymCard(gym: .sample, distance: 2.3, onSelect: {})
            SpotterRequestCard(
                request: SpotterRequest(
                    requesterId: "user_1",
                    gymId: "gym_1",
                    message: "Need a spot on bench press, going for 225!",
                    exercise: "Bench Press"
                ),
                requester: .sample,
                onAccept: {}
            )
        }
        .padding()
    }
    .background(Color("Background"))
}