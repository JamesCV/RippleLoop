import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var scene = GameScene(size: CGSize(
        width: GameConstants.sceneWidth,
        height: GameConstants.sceneHeight
    ))
    @State private var impulseDelegate: ImpulseDelegate?
    @State private var showImpulsePulse = false

    var body: some View {
        ZStack {
            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: triggerImpulse) {
                        Text("IMPULSE")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 52)
                    .opacity(showImpulsePulse ? 0.6 : 1)
                }
                Spacer()
            }
        }
        .onAppear {
            let delegate = ImpulseDelegate {
                showImpulsePulse.toggle()
            }
            impulseDelegate = delegate
            scene.gameDelegate = delegate
        }
    }

    private func triggerImpulse() {
        scene.useImpulseFromButton()
        withAnimation(.easeOut(duration: 0.15)) {
            showImpulsePulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showImpulsePulse = false
        }
    }
}

private final class ImpulseDelegate: GameSceneDelegate {
    private let onImpulse: () -> Void

    init(onImpulse: @escaping () -> Void) {
        self.onImpulse = onImpulse
    }

    func gameSceneDidRequestImpulse() {
        onImpulse()
    }
}

#Preview {
    ContentView()
}