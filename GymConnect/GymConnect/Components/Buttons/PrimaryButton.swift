import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("PrimaryBlue"),
                        Color("PrimaryBlue").opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 1.0 : 0.98)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryBlue")))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(Color("PrimaryBlue"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("PrimaryBlue").opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("PrimaryBlue").opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    init(icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
                .frame(width: size, height: size)
                .background(Color("Surface"))
                .cornerRadius(size * 0.3)
        }
    }
}

// MARK: - Close Button
struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("TextSecondary"))
                .frame(width: 32, height: 32)
                .background(Color("Surface"))
                .clipShape(Circle())
        }
    }
}

// MARK: - Action Button (Small)
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
        }
    }
}

// MARK: - GymConnect Button Style
struct GymConnectButtonStyle: ButtonStyle {
    let isPrimary: Bool
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(isPrimary ? .white : Color("PrimaryBlue"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isPrimary
                    ? LinearGradient(
                        gradient: Gradient(colors: [Color("PrimaryBlue"), Color("PrimaryBlue").opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : Color("PrimaryBlue").opacity(0.1)
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Previews
#Preview("Buttons") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", icon: "arrow.right") {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
        PrimaryButton(title: "Disabled", isDisabled: true) {}
        
        SecondaryButton(title: "Cancel") {}
        SecondaryButton(title: "Loading...", isLoading: true) {}
        
        HStack(spacing: 16) {
            IconButton(icon: "message.fill") {}
            IconButton(icon: "dumbbell.fill") {}
            IconButton(icon: "person.fill") {}
        }
        
        HStack(spacing: 12) {
            ActionButton(title: "Message", icon: "message.fill", color: Color("PrimaryBlue")) {}
            ActionButton(title: "Spot", icon: "hands.sparkles.fill", color: Color("EnergyOrange")) {}
        }
    }
    .padding()
    .background(Color("Background"))
}