import SpriteKit

final class PearlNode: SKShapeNode {
    var collected = false

    init(lane: PearlLane) {
        super.init()
        let radius: CGFloat = lane == .high ? 10 : 8
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        fillColor = SKColor.hex("#E8F4FF", alpha: 0.95)
        strokeColor = SKColor.hex("#A8D8F0", alpha: 0.8)
        lineWidth = 1.5
        glowWidth = 2
        zPosition = 12

        let y: CGFloat
        switch lane {
        case .low: y = GameConstants.waterSurfaceY + 36
        case .mid: y = GameConstants.waterSurfaceY + 72
        case .high: y = GameConstants.waterSurfaceY + 118
        }
        position = CGPoint(x: 0, y: y)

        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 0.9),
            SKAction.moveBy(x: 0, y: -4, duration: 0.9)
        ])
        run(SKAction.repeatForever(bob))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collect() {
        guard !collected else { return }
        collected = true
        removeAllActions()
        run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.6, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}

enum PearlLane {
    case low, mid, high
}
