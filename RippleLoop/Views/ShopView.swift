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
                            ForEach(SkillTree.allCases) { tree in
                                skillTreeSection(tree)
                            }
                        } else {
                            loadoutBanner
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

    private var loadoutBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Loadout · \(progress.maxLoadoutSlots) slot\(progress.maxLoadoutSlots == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if progress.equippedItems.contains(where: { $0 != nil }) {
                    Button("Clear all") {
                        PlayerProgress.shared.clearLoadout()
                        progress.refresh()
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                }
            }

            if progress.maxLoadoutSlots < 2 {
                Text("Reach 500m to unlock a second loadout slot")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }

            HStack(spacing: 10) {
                ForEach(0..<progress.maxLoadoutSlots, id: \.self) { slot in
                    loadoutSlotView(slot: slot)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private func loadoutSlotView(slot: Int) -> some View {
        let equipped = progress.equippedItem(in: slot)

        return VStack(alignment: .leading, spacing: 6) {
            Text("Slot \(slot + 1)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))

            if let equipped {
                Text(equipped.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
                    .lineLimit(2)
                Button("Remove") {
                    PlayerProgress.shared.equipItem(nil, slot: slot)
                    progress.refresh()
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
            } else {
                Text("Empty")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func skillTreeSection(_ tree: SkillTree) -> some View {
        let unlocked = progress.isSkillTreeUnlocked(tree)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(tree.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? .white : .white.opacity(0.45))
                Spacer()
                if unlocked {
                    Text("Unlocked")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9BE7A8"))
                } else {
                    Text("\(Int(tree.unlockDistanceMeters))m to unlock")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }

            if unlocked {
                ForEach(tree.upgrades) { upgrade in
                    skillRow(upgrade)
                }
            } else {
                Text("Run farther to discover \(tree.title.lowercased()) skills")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(.white.opacity(unlocked ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 16))
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
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }

    private func itemRow(_ item: ShopItemKind) -> some View {
        let owned = progress.itemCount(item)
        let equippedSlots = progress.equippedSlots(for: item)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(item.tier == .common ? "Common" : "Uncommon")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                item.tier == .common ? Color.white.opacity(0.15) : Color(hex: "#9BE7A8").opacity(0.35),
                                in: Capsule()
                            )
                            .foregroundStyle(item.tier == .common ? .white.opacity(0.75) : Color(hex: "#9BE7A8"))
                    }
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
                    ForEach(0..<progress.maxLoadoutSlots, id: \.self) { slot in
                        let isEquipped = equippedSlots.contains(slot)
                        Button {
                            PlayerProgress.shared.equipItem(isEquipped ? nil : item, slot: slot)
                            progress.refresh()
                            session.showToast(isEquipped ? "Removed from slot \(slot + 1)" : "Equipped to slot \(slot + 1)")
                        } label: {
                            Text(isEquipped ? "S\(slot + 1) ✓" : "S\(slot + 1)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isEquipped ? Color(hex: "#FFD878") : Color.white.opacity(0.15),
                                    in: Capsule()
                                )
                                .foregroundStyle(isEquipped ? Color(hex: "#2A3848") : .white)
                        }
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
    @Published var equippedItems: [ShopItemKind?] = PlayerProgress.shared.equippedItemsForNextRun
    @Published var maxLoadoutSlots = PlayerProgress.shared.maxLoadoutSlots
    @Published var bestDistance = PlayerProgress.shared.bestDistanceMeters

    func refresh() {
        ripples = PlayerProgress.shared.ripples
        equippedItems = PlayerProgress.shared.equippedItemsForNextRun
        maxLoadoutSlots = PlayerProgress.shared.maxLoadoutSlots
        bestDistance = PlayerProgress.shared.bestDistanceMeters
    }

    func level(for upgrade: UpgradeKind) -> Int {
        PlayerProgress.shared.level(for: upgrade)
    }

    func itemCount(_ item: ShopItemKind) -> Int {
        PlayerProgress.shared.itemCount(item)
    }

    func isSkillTreeUnlocked(_ tree: SkillTree) -> Bool {
        PlayerProgress.shared.isSkillTreeUnlocked(tree)
    }

    func equippedItem(in slot: Int) -> ShopItemKind? {
        PlayerProgress.shared.equippedItem(in: slot)
    }

    func equippedSlots(for item: ShopItemKind) -> [Int] {
        equippedItems.enumerated().compactMap { index, equipped in
            equipped == item ? index : nil
        }
    }
}
