import SwiftUI

struct RootView: View {
    @StateObject private var session = GameSession()

    var body: some View {
        ZStack {
            switch session.screen {
            case .dock:
                DockMenuView()
                    .transition(.opacity)
            case .playing, .lastRipple:
                GameContainerView()
                    .transition(.opacity)
            case .results:
                if let summary = session.lastSummary {
                    ResultsView(summary: summary)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            case .shop:
                ShopView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .environmentObject(session)
        .animation(.easeInOut(duration: 0.35), value: session.screen)
        .overlay(alignment: .top) {
            if let toast = session.toastMessage {
                Text(toast)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 56)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            session.toastMessage = nil
                        }
                    }
            }
        }
    }
}

#Preview {
    RootView()
}
