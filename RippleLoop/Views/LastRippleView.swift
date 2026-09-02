import SwiftUI

struct LastRippleView: View {
    let state: ContinueState
    let onAction: (ContinueAction) -> Void

    @State private var countdown = 5
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Last Ripple?")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(String(format: "%.0f m · %d skips", state.distanceMeters, state.skipCount))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                Text("\(countdown)")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
                    .padding(.vertical, 8)

                VStack(spacing: 12) {
                    if state.canWatchAd {
                        continueButton(title: "Watch ad to continue", icon: "play.rectangle") {
                            stopTimer()
                            onAction(.watchAd)
                        }
                    }

                    if PlayerProgress.shared.canUseDailyFreeContinue {
                        continueButton(title: "Free daily continue", icon: "gift") {
                            stopTimer()
                            onAction(.freeDaily)
                        }
                    }

                    if state.canSpendPebbles {
                        continueButton(
                            title: "Spend \(state.pebbleCost) Pebbles",
                            icon: "circle.fill"
                        ) {
                            stopTimer()
                            onAction(.spendPebbles)
                        }
                    }

                    Button("Let go") {
                        stopTimer()
                        onAction(.decline)
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 4)
                }
            }
            .padding(32)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private func continueButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(hex: "#2A3848"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(hex: "#9BE7A8"), in: Capsule())
        }
    }

    private func startTimer() {
        countdown = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                countdown -= 1
                if countdown <= 0 {
                    stopTimer()
                    onAction(.decline)
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
