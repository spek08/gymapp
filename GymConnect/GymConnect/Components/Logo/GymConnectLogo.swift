import SwiftUI

enum LogoStyle {
    case full        // Icon + wordmark
    case icon        // Icon only
    case minimal     // Just GC letters
}

enum LogoSize {
    case small      // 24pt
    case medium     // 40pt
    case large      // 60pt
    case xlarge     // 100pt
    case appIcon    // 1024pt (for export)
    
    var value: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 40
        case .large: return 60
        case .xlarge: return 100
        case .appIcon: return 1024
        }
    }
}

struct GymConnectLogo: View {
    let style: LogoStyle
    let size: LogoSize
    var isAnimated: Bool = false
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        switch style {
        case .full:
            HStack(spacing: size.value * 0.15) {
                iconView
                Text("GymConnect")
                    .font(.system(size: size.value * 0.6, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        case .icon:
            iconView
        case .minimal:
            minimalView
        }
    }
    
    private var iconView: some View {
        ZStack {
            // Outer ring with gradient
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color("PrimaryBlue"),
                            Color("EnergyOrange"),
                            Color("PrimaryBlue")
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    lineWidth: size.value * 0.08
                )
                .frame(width: size.value, height: size.value)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .onAppear {
                    if isAnimated {
                        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            scale = 1.05
                        }
                    }
                }
            
            // Inner circle (background)
            Circle()
                .fill(Color("Surface"))
                .frame(width: size.value * 0.85, height: size.value * 0.85)
            
            // GC letters
            HStack(spacing: -size.value * 0.08) {
                Text("G")
                    .font(.system(size: size.value * 0.45, weight: .black, design: .rounded))
                    .foregroundColor(Color("PrimaryBlue"))
                
                Text("C")
                    .font(.system(size: size.value * 0.45, weight: .black, design: .rounded))
                    .foregroundColor(Color("EnergyOrange"))
            }
            .scaleEffect(scale)
        }
    }
    
    private var minimalView: some View {
        HStack(spacing: -size.value * 0.05) {
            Text("G")
                .font(.system(size: size.value, weight: .black, design: .rounded))
                .foregroundColor(Color("PrimaryBlue"))
            
            Text("C")
                .font(.system(size: size.value, weight: .black, design: .rounded))
                .foregroundColor(Color("EnergyOrange"))
        }
    }
}

// MARK: - Animated Logo for Splash Screen
struct AnimatedLogo: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            GymConnectLogo(style: .icon, size: .xlarge, isAnimated: true)
            
            Text("GymConnect")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            Text("Find your gym squad")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                AnimatedLogo()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Full Logo") {
    ZStack {
        Color("Background").ignoresSafeArea()
        GymConnectLogo(style: .full, size: .large)
    }
}

#Preview("Icon Only") {
    ZStack {
        Color("Background").ignoresSafeArea()
        GymConnectLogo(style: .icon, size: .xlarge, isAnimated: true)
    }
}

#Preview("Minimal") {
    ZStack {
        Color("Background").ignoresSafeArea()
        GymConnectLogo(style: .minimal, size: .large)
    }
}

#Preview("Splash Screen") {
    SplashScreenView()
}