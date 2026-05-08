import SwiftUI

// Custom navigation transitions
extension AnyTransition {
    static var slideFromRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
    
    static var slideFromBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .bottom)
        )
    }
    
    static var fadeAndScale: AnyTransition {
        .opacity.combined(with: .scale)
    }
}

// Navigation animation modifiers
struct NavigationTransitionModifier: ViewModifier {
    let transition: AnyTransition
    
    func body(content: Content) -> some View {
        content
            .transition(transition)
            .animation(.easeInOut(duration: 0.3), value: UUID())
    }
}

extension View {
    func withNavigationTransition(_ transition: AnyTransition = .slideFromRight) -> some View {
        modifier(NavigationTransitionModifier(transition: transition))
    }
}