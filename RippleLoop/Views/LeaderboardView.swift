import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var session: GameSession
    @ObservedObject private var gameCenter = GameCenterService.shared
    @State private var scope: LeaderboardScope = .global

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#3E8798"), Color(hex: "#2A5868")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if !gameCenter.isAuthenticated {
                    signInPrompt
                } else {
                    scopePicker
                    leaderboardList
                }
            }
        }
        .background {
            GameCenterAuthPresenter(viewController: gameCenter.authenticationViewController)
        }
        .task {
            if gameCenter.isAuthenticated {
                await gameCenter.refreshLeaderboards()
            }
        }
        .onChange(of: scope) { _, _ in
            HapticManager.menuTap()
        }
    }

    private var header: some View {
        HStack {
            Button {
                HapticManager.menuTap()
                session.returnToDock()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Text("Leaderboard")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button {
                Task { await gameCenter.refreshLeaderboards() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .disabled(gameCenter.isLoadingLeaderboard)
        }
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 16)
    }

    private var signInPrompt: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.2.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.7))
            Text("Sign in to Game Center")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("Compare your best skip distance with players worldwide and friends.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if let error = gameCenter.authError {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            Spacer()
        }
    }

    private var scopePicker: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardScope.allCases) { item in
                Button {
                    scope = item
                } label: {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            scope == item ? Color.white.opacity(0.95) : Color.white.opacity(0.12),
                            in: Capsule()
                        )
                        .foregroundStyle(scope == item ? Color(hex: "#2A5868") : .white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var leaderboardList: some View {
        let entries = gameCenter.entries(for: scope)

        return ScrollView {
            VStack(spacing: 10) {
                if let rank = gameCenter.localRank, let best = gameCenter.localBestMeters, scope == .global {
                    localPlayerCard(rank: rank, best: best)
                }

                if gameCenter.isLoadingLeaderboard {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 40)
                } else if entries.isEmpty {
                    Text(scope == .friends ? "No friends on the board yet." : "No scores yet. Be the first!")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.top, 40)
                } else {
                    ForEach(entries) { entry in
                        leaderboardRow(entry)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func localPlayerCard(rank: Int, best: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your rank")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                Text("#\(rank)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Best")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                Text("\(best) m")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 4)
    }

    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        HStack(spacing: 14) {
            Text("#\(entry.rank)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(entry.isLocalPlayer ? Color(hex: "#FFD878") : .white.opacity(0.7))
                .frame(width: 44, alignment: .leading)

            Text(entry.name)
                .font(.system(size: 16, weight: entry.isLocalPlayer ? .semibold : .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Text("\(entry.scoreMeters) m")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.isLocalPlayer ? Color(hex: "#9BE7A8") : .white.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            entry.isLocalPlayer ? Color.white.opacity(0.16) : Color.white.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}
