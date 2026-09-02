import Foundation
import Combine

enum AppScreen: Equatable {
    case dock
    case playing
    case lastRipple
    case results
    case shop
    case leaderboard
    case settings
}

@MainActor
final class GameSession: ObservableObject {
    @Published var screen: AppScreen = .dock
    @Published var lastSummary: RunSummary?
    @Published var pendingContinue: ContinueState?
    @Published var toastMessage: String?
    @Published var runGeneration = 0

    var progress: PlayerProgress { PlayerProgress.shared }

    func startRun() {
        lastSummary = nil
        pendingContinue = nil
        runGeneration += 1
        screen = .playing
    }

    func showLastRipple(_ state: ContinueState) {
        pendingContinue = state
        screen = .lastRipple
    }

    func finishRun(_ summary: RunSummary) {
        lastSummary = summary
        pendingContinue = nil
        screen = .results

        Task {
            await GameCenterService.shared.submitBestDistance(summary.distanceMeters)
        }
    }

    func returnToDock() {
        screen = .dock
    }

    func openShop() {
        screen = .shop
    }

    func openLeaderboard() {
        screen = .leaderboard
    }

    func openSettings() {
        screen = .settings
    }

    func resumeAfterContinue() {
        screen = .playing
    }

    func showToast(_ message: String) {
        toastMessage = message
    }
}

struct ContinueState: Equatable {
    let distanceMeters: Double
    let skipCount: Int
    let comboMultiplier: Int
    let pearlsCollected: Int
    let canContinue: Bool
}
