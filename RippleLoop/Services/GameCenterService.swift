import Foundation
import GameKit

enum LeaderboardScope: String, CaseIterable, Identifiable {
    case global
    case friends

    var id: String { rawValue }

    var title: String {
        switch self {
        case .global: return "Global"
        case .friends: return "Friends"
        }
    }
}

struct LeaderboardEntry: Identifiable, Equatable {
    let id: String
    let rank: Int
    let name: String
    let scoreMeters: Int
    let isLocalPlayer: Bool

    init(rank: Int, name: String, scoreMeters: Int, isLocalPlayer: Bool, playerID: String) {
        self.id = "\(playerID)-\(rank)"
        self.rank = rank
        self.name = name
        self.scoreMeters = scoreMeters
        self.isLocalPlayer = isLocalPlayer
    }
}

@MainActor
final class GameCenterService: ObservableObject {
    static let shared = GameCenterService()

    static let bestDistanceLeaderboardID = "com.rippleloop.game.bestdistance"

    @Published private(set) var isAuthenticated = false
    @Published private(set) var localPlayerName = ""
    @Published private(set) var authError: String?
    @Published var authenticationViewController: UIViewController?

    @Published private(set) var globalEntries: [LeaderboardEntry] = []
    @Published private(set) var friendsEntries: [LeaderboardEntry] = []
    @Published private(set) var isLoadingLeaderboard = false
    @Published private(set) var localRank: Int?
    @Published private(set) var localBestMeters: Int?

    private init() {}

    func authenticate() {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self else { return }
                if let viewController {
                    self.authenticationViewController = viewController
                } else {
                    self.authenticationViewController = nil
                }

                if let error {
                    self.authError = error.localizedDescription
                    self.isAuthenticated = false
                    self.localPlayerName = ""
                    return
                }

                self.authError = nil
                self.isAuthenticated = player.isAuthenticated
                self.localPlayerName = player.isAuthenticated ? player.displayName : ""

                if player.isAuthenticated {
                    await self.refreshLeaderboards()
                }
            }
        }
    }

    func submitBestDistance(_ meters: Double) async {
        guard isAuthenticated else { return }
        let score = max(0, Int(meters.rounded()))
        guard score > 0 else { return }

        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [Self.bestDistanceLeaderboardID]
            )
            await refreshLeaderboards()
        } catch {
            authError = error.localizedDescription
        }
    }

    func refreshLeaderboards() async {
        guard isAuthenticated else {
            globalEntries = []
            friendsEntries = []
            localRank = nil
            localBestMeters = nil
            return
        }

        isLoadingLeaderboard = true
        defer { isLoadingLeaderboard = false }

        do {
            globalEntries = try await loadEntries(for: .global)
            friendsEntries = try await loadEntries(for: .friends)
        } catch {
            authError = error.localizedDescription
        }
    }

    func entries(for scope: LeaderboardScope) -> [LeaderboardEntry] {
        switch scope {
        case .global: return globalEntries
        case .friends: return friendsEntries
        }
    }

    private func loadEntries(for scope: LeaderboardScope) async throws -> [LeaderboardEntry] {
        let boards = try await GKLeaderboard.loadLeaderboards(IDs: [Self.bestDistanceLeaderboardID])
        guard let board = boards.first else { return [] }

        let playerScope: GKLeaderboard.PlayerScope = scope == .global ? .global : .friends
        let (local, entries, _) = try await board.loadEntries(
            for: playerScope,
            timeScope: .allTime,
            range: NSRange(location: 1, length: 50)
        )

        if scope == .global, let local {
            localRank = local.rank
            localBestMeters = local.score
        }

        return entries?.map { entry in
            LeaderboardEntry(
                rank: entry.rank,
                name: entry.player.displayName,
                scoreMeters: entry.score,
                isLocalPlayer: entry.player == GKLocalPlayer.local,
                playerID: entry.player.gamePlayerID
            )
        } ?? []
    }
}
