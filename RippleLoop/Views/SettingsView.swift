import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: GameSession
    @ObservedObject private var settings = GameplaySettings.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#4A5868"), Color(hex: "#3A4858")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
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
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 24)

                VStack(spacing: 12) {
                    toggleRow(title: "Sound", subtitle: "Skip tones and ambient feedback", isOn: $settings.soundEnabled)
                    toggleRow(title: "Haptics", subtitle: "Gentle taps on skips and bounces", isOn: $settings.hapticsEnabled)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .tint(Color(hex: "#9BE7A8"))
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .onChange(of: isOn.wrappedValue) { _, _ in
            HapticManager.menuTap()
            SoundManager.shared.playMenuTap()
        }
    }
}
