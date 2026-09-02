import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @EnvironmentObject private var session: GameSession
    @State private var scene = GameScene(size: CGSize(
        width: GameConstants.sceneWidth,
        height: GameConstants.sceneHeight
    ))

    var body: some View {
        ZStack {
            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            if session.screen == .lastRipple, let state = session.pendingContinue {
                LastRippleView(state: state) { action in
                    handleContinueAction(action)
                }
                .transition(.opacity)
            }
        }
        .id(session.runGeneration)
        .onAppear {
            scene.host = GameSceneCoordinator(session: session, scene: scene)
            scene.beginRun()
        }
    }

    private func handleContinueAction(_ action: ContinueAction) {
        switch action {
        case .continueRun:
            HapticManager.doubleBounce()
            SoundManager.shared.playDoubleBounce()
            session.resumeAfterContinue()
            scene.resumeFromContinue()
        case .decline:
            session.finishRun(buildDeclineSummary(from: session.pendingContinue))
        }
    }

    private func buildDeclineSummary(from state: ContinueState?) -> RunSummary {
        guard let state else {
            return RunSummary(
                distanceMeters: 0, skipCount: 0, bestDistanceMeters: PlayerProgress.shared.bestDistanceMeters,
                isNewBest: false, ripplesEarned: 0, pearlsCollected: 0, comboPeak: 0, biomeReached: Biome.goldenHour.displayName
            )
        }
        return PlayerProgress.shared.recordRun(
            distanceMeters: state.distanceMeters,
            skipCount: state.skipCount,
            pearlsCollected: state.pearlsCollected,
            comboPeak: state.comboMultiplier,
            biome: Biome.forDistance(state.distanceMeters)
        )
    }
}

@MainActor
final class GameSceneCoordinator: GameSceneHost {
    private let session: GameSession
    private weak var scene: GameScene?

    init(session: GameSession, scene: GameScene) {
        self.session = session
        self.scene = scene
    }

    func gameSceneDidRequestLastRipple(_ state: ContinueState) {
        session.showLastRipple(state)
    }

    func gameSceneDidFinish(_ summary: RunSummary) {
        if summary.isNewBest {
            HapticManager.newBest()
            SoundManager.shared.playNewBest()
        }
        session.finishRun(summary)
    }
}
