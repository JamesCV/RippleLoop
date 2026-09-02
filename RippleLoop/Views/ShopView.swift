import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var session: GameSession
    @ObservedObject private var progress = ShopProgressObserver()

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
                        session.returnToDock()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Text("Workbench")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("◦ \(progress.ripples)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FFD878"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(UpgradeKind.allCases) { upgrade in
                            upgradeRow(upgrade)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            progress.refresh()
        }
    }

    private func upgradeRow(_ upgrade: UpgradeKind) -> some View {
        let level = progress.level(for: upgrade)
        let maxed = level >= upgrade.maxLevel
        let cost = upgrade.cost(forLevel: level)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(upgrade.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(upgrade.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                Text(maxed ? "MAX" : "Lv \(level)/\(upgrade.maxLevel)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#9BE7A8"))
            }

            if !maxed {
                Button {
                    if PlayerProgress.shared.purchaseUpgrade(upgrade) {
                        progress.refresh()
                        session.showToast("Upgraded \(upgrade.title)")
                    }
                } label: {
                    Text("\(cost) Ripples")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            progress.ripples >= cost
                                ? Color(hex: "#9BE7A8")
                                : Color.white.opacity(0.15),
                            in: Capsule()
                        )
                        .foregroundStyle(
                            progress.ripples >= cost
                                ? Color(hex: "#2A3848")
                                : .white.opacity(0.45)
                        )
                }
                .disabled(progress.ripples < cost)
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}

@MainActor
final class ShopProgressObserver: ObservableObject {
    @Published var ripples = PlayerProgress.shared.ripples

    func refresh() {
        ripples = PlayerProgress.shared.ripples
    }

    func level(for upgrade: UpgradeKind) -> Int {
        PlayerProgress.shared.level(for: upgrade)
    }
}
