import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var session: GameSession
    @ObservedObject private var progress = ShopProgressObserver()
    @State private var category: ShopCategory = .skills

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#4A5868"), Color(hex: "#3A4858")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                categoryPicker

                ScrollView {
                    VStack(spacing: 14) {
                        if category == .skills {
                            ForEach(UpgradeKind.allCases) { upgrade in
                                skillRow(upgrade)
                            }
                        } else {
                            equippedBanner
                            ForEach(ShopItemKind.allCases) { item in
                                itemRow(item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { progress.refresh() }
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
            Text("Dock Shop")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Text("◦ \(progress.ripples)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#FFD878"))
        }
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 16)
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(ShopCategory.allCases) { tab in
                Button {
                    category = tab
                    HapticManager.menuTap()
                } label: {
                    Text(tab.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            category == tab ? Color(hex: "#9BE7A8") : Color.white.opacity(0.12),
                            in: Capsule()
                        )
                        .foregroundStyle(category == tab ? Color(hex: "#2A3848") : .white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    private var equippedBanner: some View {
        Group {
            if let equipped = progress.equippedItem {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Equipped for next run")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.65))
                        Text(equipped.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#FFD878"))
                    }
                    Spacer()
                    Button("Clear") {
                        PlayerProgress.shared.equipItem(nil)
                        progress.refresh()
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                }
                .padding(14)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func skillRow(_ upgrade: UpgradeKind) -> some View {
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
                purchaseButton(title: "\(cost) Ripples", enabled: progress.ripples >= cost) {
                    if PlayerProgress.shared.purchaseUpgrade(upgrade) {
                        progress.refresh()
                        session.showToast("Skill upgraded: \(upgrade.title)")
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private func itemRow(_ item: ShopItemKind) -> some View {
        let owned = progress.itemCount(item)
        let equipped = progress.equippedItem == item

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(item.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                Text("×\(owned)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
            }

            HStack(spacing: 10) {
                purchaseButton(title: "\(item.cost) Ripples", enabled: progress.ripples >= item.cost) {
                    if PlayerProgress.shared.purchaseItem(item) {
                        progress.refresh()
                        session.showToast("Purchased \(item.title)")
                    }
                }

                if owned > 0 {
                    Button {
                        PlayerProgress.shared.equipItem(equipped ? nil : item)
                        progress.refresh()
                        session.showToast(equipped ? "Item cleared" : "Equipped for next run")
                    } label: {
                        Text(equipped ? "Equipped" : "Equip")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                equipped ? Color(hex: "#FFD878") : Color.white.opacity(0.15),
                                in: Capsule()
                            )
                            .foregroundStyle(equipped ? Color(hex: "#2A3848") : .white)
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private func purchaseButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(enabled ? Color(hex: "#9BE7A8") : Color.white.opacity(0.15), in: Capsule())
                .foregroundStyle(enabled ? Color(hex: "#2A3848") : .white.opacity(0.45))
        }
        .disabled(!enabled)
    }
}

@MainActor
final class ShopProgressObserver: ObservableObject {
    @Published var ripples = PlayerProgress.shared.ripples
    @Published var equippedItem = PlayerProgress.shared.equippedItemForNextRun

    func refresh() {
        ripples = PlayerProgress.shared.ripples
        equippedItem = PlayerProgress.shared.equippedItemForNextRun
    }

    func level(for upgrade: UpgradeKind) -> Int {
        PlayerProgress.shared.level(for: upgrade)
    }

    func itemCount(_ item: ShopItemKind) -> Int {
        PlayerProgress.shared.itemCount(item)
    }
}
