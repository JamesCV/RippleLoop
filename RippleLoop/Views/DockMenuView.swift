import SwiftUI

struct DockMenuView: View {
    @EnvironmentObject private var session: GameSession
    @State private var bobOffset: CGFloat = 0
    @State private var rippleScale: CGFloat = 0.6
    @State private var rippleOpacity: Double = 0.4

    private var progress: PlayerProgress { PlayerProgress.shared }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#C9A7E8"), Color(hex: "#F5C4A8"), Color(hex: "#3E8798")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(rippleOpacity), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(rippleScale)

                    pebbleSilhouette
                        .offset(y: bobOffset)

                    Ellipse()
                        .fill(Color(hex: "#8B6914"))
                        .frame(width: 200, height: 16)
                        .offset(y: 48)
                }
                .frame(height: 180)
                .padding(.bottom, 12)

                Text("Ripple Run")
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                Text("Skip the endless lake")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)

                HStack(spacing: 20) {
                    statBadge(title: "Best", value: String(format: "%.0fm", progress.bestDistanceMeters))
                    statBadge(title: "Ripples", value: "\(progress.ripples)")
                }
                .padding(.top, 24)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        HapticManager.menuTap()
                        SoundManager.shared.playMenuTap()
                        session.startRun()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Play")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white.opacity(0.95), in: Capsule())
                        .foregroundStyle(Color(hex: "#3A4858"))
                    }

                    HStack(spacing: 12) {
                        dockButton(title: "Shop", icon: "hammer") {
                            HapticManager.menuTap()
                            SoundManager.shared.playMenuTap()
                            session.openShop()
                        }
                        dockButton(title: "Board", icon: "trophy") {
                            HapticManager.menuTap()
                            SoundManager.shared.playMenuTap()
                            session.openLeaderboard()
                        }
                        dockButton(title: "Settings", icon: "slider.horizontal.3") {
                            HapticManager.menuTap()
                            SoundManager.shared.playMenuTap()
                            session.openSettings()
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                bobOffset = -5
            }
            withAnimation(.easeOut(duration: 2.4).repeatForever(autoreverses: false)) {
                rippleScale = 1.6
                rippleOpacity = 0
            }
        }
    }

    private var pebbleSilhouette: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "#3A4858"))
                .frame(width: 22, height: 32)
                .offset(y: 8)

            Ellipse()
                .fill(Color(hex: "#4A5868"))
                .frame(width: 30, height: 18)
                .offset(y: -10)

            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 14, height: 10)
                .offset(x: 12, y: 2)
                .rotationEffect(.degrees(-20))
        }
    }

    private func statBadge(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.white.opacity(0.12), in: Capsule())
    }

    private func dockButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.15), in: Capsule())
            .foregroundStyle(.white)
        }
    }
}
