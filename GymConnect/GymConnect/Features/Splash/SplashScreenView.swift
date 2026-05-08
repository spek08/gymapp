import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    GymConnectLogo(style: .icon, size: .xlarge, isAnimated: true)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("GymConnect")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                    
                    Text("Find your gym squad")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}