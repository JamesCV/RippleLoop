import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var session: GameSession
    let summary: RunSummary

    @State private var displayedRipples = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#C9A7E8"), Color(hex: "#F5C4A8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text(summary.isNewBest ? "New Best" : "Run Complete")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 8) {
                    Text(String(format: "%.0f m", summary.distanceMeters))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(summary.skipCount) skips · ×\(summary.comboPeak) combo")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))

                    Text(summary.biomeReached)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                }

                VStack(spacing: 6) {
                    Text("+\(displayedRipples) Ripples")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FFD878"))

                    Text("\(summary.pearlsCollected) pearls collected")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.vertical, 8)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        session.startRun()
                    } label: {
                        Text("Skip Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white.opacity(0.95), in: Capsule())
                            .foregroundStyle(Color(hex: "#3A4858"))
                    }

                    Button {
                        session.returnToDock()
                    } label: {
                        Text("Return to Dock")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateRipples()
        }
    }

    private func animateRipples() {
        displayedRipples = 0
        let target = summary.ripplesEarned
        guard target > 0 else { return }
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            Task { @MainActor in
                displayedRipples = min(displayedRipples + max(1, target / 30), target)
                if displayedRipples >= target {
                    timer.invalidate()
                }
            }
        }
    }
}
