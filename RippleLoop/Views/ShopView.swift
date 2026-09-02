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
                        switch category {
                        case .skills:
                            ForEach(SkillTree.allCases) { tree in
                                skillTreeSection(tree)
                            }
                        case .items:
                            loadoutBanner
                            ForEach(ShopItemKind.allCases) { item in
                                itemRow(item)
                            }
                        case .stones:
                            equippedStoneBanner
                            ForEach(StoneKind.allCases) { stone in
                                stoneRow(stone)
                            }
                        case .outfits:
                            equippedOutfitBanner
                            ForEach(PebbleOutfitKind.allCases) { outfit in
                                outfitRow(outfit)
                            }
                        case .dock:
                            dockTierBanner
                            if progress.isDockTabUnlocked {
                                ForEach(DockUpgradeKind.allCases) { upgrade in
                                    dockUpgradeRow(upgrade)
                                }
                            } else {
                                dockLockedBanner
                            }
                        case .blessings:
                            blessingLoadoutBanner
                            if progress.isBlessingsTabUnlocked {
                                ForEach(BlessingKind.allCases) { blessing in
                                    blessingRow(blessing)
                                }
                            } else {
                                blessingsLockedBanner
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShopCategory.allCases) { tab in
                    Button {
                        category = tab
                        HapticManager.menuTap()
                    } label: {
                        Text(tab.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16)
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
        }
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

            if progress.maxLoadoutSlots < 3 {
                Text(loadoutUnlockHint)
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
                        Text(item.tier.label)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(tierBadgeColor(item.tier).opacity(0.35), in: Capsule())
                            .foregroundStyle(tierBadgeColor(item.tier))
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

    private var loadoutUnlockHint: String {
        if progress.bestDistance < 500 {
            return "Reach 500m to unlock a second loadout slot"
        }
        return "Reach 1500m to unlock a third loadout slot"
    }

    private var equippedStoneBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Equipped stone")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                Text(progress.equippedStone.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
            }
            Spacer()
            Circle()
                .fill(Color(hex: progress.equippedStone.fillHex))
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color(hex: progress.equippedStone.strokeHex), lineWidth: 2))
        }
        .padding(14)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private var equippedOutfitBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pebble outfit")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                Text(progress.equippedOutfit.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFD878"))
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: progress.equippedOutfit.hoodHex))
                .frame(width: 22, height: 28)
        }
        .padding(14)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private func stoneRow(_ stone: StoneKind) -> some View {
        let owned = progress.ownsStone(stone)
        let equipped = progress.equippedStone == stone
        let unlocked = progress.bestDistance >= stone.unlockDistanceMeters

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(hex: stone.fillHex))
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(Color(hex: stone.strokeHex), lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    Text(stone.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(unlocked ? .white : .white.opacity(0.45))
                    Text(stone.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(unlocked ? 0.65 : 0.4))
                }
                Spacer()
                if owned {
                    Text(equipped ? "Equipped" : "Owned")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9BE7A8"))
                }
            }

            if !unlocked {
                Text("\(Int(stone.unlockDistanceMeters))m to unlock")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            } else if owned {
                if !equipped {
                    purchaseButton(title: "Equip", enabled: true) {
                        PlayerProgress.shared.equipStone(stone)
                        progress.refresh()
                        session.showToast("Equipped \(stone.title)")
                    }
                }
            } else if stone.cost > 0 {
                purchaseButton(title: "\(stone.cost) Ripples", enabled: progress.ripples >= stone.cost) {
                    if PlayerProgress.shared.purchaseStone(stone) {
                        PlayerProgress.shared.equipStone(stone)
                        progress.refresh()
                        session.showToast("Unlocked \(stone.title)")
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(unlocked ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 16))
    }

    private func outfitRow(_ outfit: PebbleOutfitKind) -> some View {
        let owned = progress.ownsOutfit(outfit)
        let equipped = progress.equippedOutfit == outfit
        let unlocked = progress.bestDistance >= outfit.unlockDistanceMeters

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: outfit.hoodHex))
                    .frame(width: 28, height: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(outfit.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(unlocked ? .white : .white.opacity(0.45))
                    Text(outfit.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(unlocked ? 0.65 : 0.4))
                }
                Spacer()
                if owned {
                    Text(equipped ? "Equipped" : "Owned")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9BE7A8"))
                }
            }

            if !unlocked {
                Text("\(Int(outfit.unlockDistanceMeters))m to unlock")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            } else if owned {
                if !equipped {
                    purchaseButton(title: "Equip", enabled: true) {
                        PlayerProgress.shared.equipOutfit(outfit)
                        progress.refresh()
                        session.showToast("Equipped \(outfit.title)")
                    }
                }
            } else if outfit.cost > 0 {
                purchaseButton(title: "\(outfit.cost) Ripples", enabled: progress.ripples >= outfit.cost) {
                    if PlayerProgress.shared.purchaseOutfit(outfit) {
                        PlayerProgress.shared.equipOutfit(outfit)
                        progress.refresh()
                        session.showToast("Unlocked \(outfit.title)")
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(unlocked ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 16))
    }

    private func tierBadgeColor(_ tier: ItemTier) -> Color {
        switch tier {
        case .common: return .white.opacity(0.75)
        case .uncommon: return Color(hex: "#9BE7A8")
        case .rare: return Color(hex: "#FFD878")
        }
    }

    private var dockTierBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dock tier")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                    Text(progress.dockTier.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FFD878"))
                }
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: progress.dockTier.plankHex))
                    .frame(width: 64, height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: progress.dockTier.strokeHex), lineWidth: 1)
                    )
            }
            Text("Upgrade the dock to improve every run and unlock cozy lantern lights.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(14)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private var dockLockedBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dock upgrades locked")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
            Text("Reach \(Int(ShopCategory.dockTabUnlockDistanceMeters))m to renovate the dock.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
    }

    private func dockUpgradeRow(_ upgrade: DockUpgradeKind) -> some View {
        let level = progress.dockLevel(for: upgrade)
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
                    .foregroundStyle(Color(hex: "#FFD878"))
            }

            if !maxed {
                purchaseButton(title: "\(cost) Ripples", enabled: progress.ripples >= cost) {
                    if PlayerProgress.shared.purchaseDockUpgrade(upgrade) {
                        progress.refresh()
                        session.showToast("Dock upgraded: \(upgrade.title)")
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var blessingLoadoutBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Blessings · \(progress.maxBlessingSlots) slot\(progress.maxBlessingSlots == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if progress.equippedBlessings.contains(where: { $0 != nil }) {
                    Button("Clear all") {
                        PlayerProgress.shared.clearBlessingLoadout()
                        progress.refresh()
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                }
            }

            if progress.maxBlessingSlots < 2 && progress.isBlessingsTabUnlocked {
                Text("Reach 4000m to equip two blessings")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }

            if progress.maxBlessingSlots > 0 {
                HStack(spacing: 10) {
                    ForEach(0..<progress.maxBlessingSlots, id: \.self) { slot in
                        blessingSlotView(slot: slot)
                    }
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private func blessingSlotView(slot: Int) -> some View {
        let equipped = progress.equippedBlessing(in: slot)

        return VStack(alignment: .leading, spacing: 6) {
            Text("Blessing \(slot + 1)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))

            if let equipped {
                Text(equipped.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: equipped.accentHex))
                    .lineLimit(2)
                Button("Remove") {
                    PlayerProgress.shared.equipBlessing(nil, slot: slot)
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

    private var blessingsLockedBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lake blessings locked")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
            Text("Reach \(Int(ShopCategory.blessingsTabUnlockDistanceMeters))m to receive blessings from the lake.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
    }

    private func blessingRow(_ blessing: BlessingKind) -> some View {
        let owned = progress.ownsBlessing(blessing)
        let equippedSlots = progress.equippedBlessingSlots(for: blessing)
        let unlocked = progress.bestDistance >= blessing.unlockDistanceMeters

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(hex: blessing.accentHex).opacity(0.35))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: blessing.accentHex), lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(blessing.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(unlocked ? .white : .white.opacity(0.45))
                    Text(blessing.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(unlocked ? 0.65 : 0.4))
                }
                Spacer()
                if owned {
                    Text("Owned")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: blessing.accentHex))
                }
            }

            if !unlocked {
                Text("\(Int(blessing.unlockDistanceMeters))m to unlock")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            } else if owned {
                HStack(spacing: 10) {
                    ForEach(0..<progress.maxBlessingSlots, id: \.self) { slot in
                        let isEquipped = equippedSlots.contains(slot)
                        Button {
                            PlayerProgress.shared.equipBlessing(isEquipped ? nil : blessing, slot: slot)
                            progress.refresh()
                            session.showToast(isEquipped ? "Blessing removed" : "Blessing equipped")
                        } label: {
                            Text(isEquipped ? "B\(slot + 1) ✓" : "B\(slot + 1)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isEquipped ? Color(hex: blessing.accentHex) : Color.white.opacity(0.15),
                                    in: Capsule()
                                )
                                .foregroundStyle(isEquipped ? Color(hex: "#2A3848") : .white)
                        }
                    }
                }
            } else {
                purchaseButton(title: "\(blessing.cost) Ripples", enabled: progress.ripples >= blessing.cost) {
                    if PlayerProgress.shared.purchaseBlessing(blessing) {
                        progress.refresh()
                        session.showToast("Blessing unlocked: \(blessing.title)")
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(unlocked ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 16))
    }
}

@MainActor
final class ShopProgressObserver: ObservableObject {
    @Published var ripples = PlayerProgress.shared.ripples
    @Published var equippedItems: [ShopItemKind?] = PlayerProgress.shared.equippedItemsForNextRun
    @Published var maxLoadoutSlots = PlayerProgress.shared.maxLoadoutSlots
    @Published var bestDistance = PlayerProgress.shared.bestDistanceMeters
    @Published var equippedStone = PlayerProgress.shared.equippedStone
    @Published var equippedOutfit = PlayerProgress.shared.equippedOutfit
    @Published var dockTier = PlayerProgress.shared.dockTier
    @Published var equippedBlessings: [BlessingKind?] = PlayerProgress.shared.equippedBlessingsForNextRun
    @Published var maxBlessingSlots = PlayerProgress.shared.maxBlessingSlots

    func refresh() {
        ripples = PlayerProgress.shared.ripples
        equippedItems = PlayerProgress.shared.equippedItemsForNextRun
        maxLoadoutSlots = PlayerProgress.shared.maxLoadoutSlots
        bestDistance = PlayerProgress.shared.bestDistanceMeters
        equippedStone = PlayerProgress.shared.equippedStone
        equippedOutfit = PlayerProgress.shared.equippedOutfit
        dockTier = PlayerProgress.shared.dockTier
        equippedBlessings = PlayerProgress.shared.equippedBlessingsForNextRun
        maxBlessingSlots = PlayerProgress.shared.maxBlessingSlots
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

    func ownsStone(_ stone: StoneKind) -> Bool {
        PlayerProgress.shared.ownsStone(stone)
    }

    func ownsOutfit(_ outfit: PebbleOutfitKind) -> Bool {
        PlayerProgress.shared.ownsOutfit(outfit)
    }

    func isDockTabUnlocked() -> Bool {
        PlayerProgress.shared.isDockTabUnlocked()
    }

    func dockLevel(for upgrade: DockUpgradeKind) -> Int {
        PlayerProgress.shared.dockLevel(for: upgrade)
    }

    func isBlessingsTabUnlocked() -> Bool {
        PlayerProgress.shared.isBlessingsTabUnlocked()
    }

    func ownsBlessing(_ blessing: BlessingKind) -> Bool {
        PlayerProgress.shared.ownsBlessing(blessing)
    }

    func equippedBlessing(in slot: Int) -> BlessingKind? {
        PlayerProgress.shared.equippedBlessing(in: slot)
    }

    func equippedBlessingSlots(for blessing: BlessingKind) -> [Int] {
        equippedBlessings.enumerated().compactMap { index, equipped in
            equipped == blessing ? index : nil
        }
    }
}
