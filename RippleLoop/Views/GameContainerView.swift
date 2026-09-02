import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @EnvironmentObject private var session: GameSession
    @State private var scene = GameScene(size: CGSize(
        width: GameConstants.sceneWidth,
        height: GameConstants.sceneHeight
    ))
    @State private var boostPulse = false

    var body: some View {
        ZStack {
            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            if session.screen == .lastRipple, let state = session.pendingContinue {
                LastRippleView(state: state) { action in
                    handleContinueAction(action)
                }
                .transition(.opacity)
            } else if session.screen == .playing {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: triggerBoost) {
                            VStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("BOOST")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color(hex: "#2A3848"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#FFD878").opacity(boostPulse ? 0.7 : 1), in: Capsule())
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 52)
                    }
                    Spacer()
                }
            }
        }
        .id(session.runGeneration)
        .onAppear {
            scene.host = GameSceneCoordinator(session: session, scene: scene)
            scene.beginRun()
        }
    }

    private func triggerBoost() {
        scene.useRippleBoostFromButton()
        withAnimation(.easeOut(duration: 0.12)) { boostPulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            boostPulse = false
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
