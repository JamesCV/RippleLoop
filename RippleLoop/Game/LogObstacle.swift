import SpriteKit

final class LogObstacle: SKNode {
    let logWidth: CGFloat = 110
    let logHeight: CGFloat = 28
    private let shadowNode = SKShapeNode()
    private let driftSpeedMultiplier: CGFloat

    init(driftSpeedMultiplier: CGFloat = 1) {
        self.driftSpeedMultiplier = driftSpeedMultiplier
        super.init()
        zPosition = 15

        shadowNode.path = CGPath(ellipseIn: CGRect(x: -logWidth * 0.4, y: -8, width: logWidth * 0.8, height: 16), transform: nil)
        shadowNode.fillColor = SKColor.black.withAlphaComponent(0.15)
        shadowNode.strokeColor = .clear
        addChild(shadowNode)

        let log = SKShapeNode(path: roundedLogPath())
        log.fillColor = SKColor.hex("#8B5A2B")
        log.strokeColor = SKColor.hex("#6B4423", alpha: 0.7)
        log.lineWidth = 1.5
        addChild(log)

        position = CGPoint(x: 0, y: GameConstants.waterSurfaceY + logHeight + 8)

        let bobDuration = 1.2 / Double(max(driftSpeedMultiplier, 0.2))
        let drift = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: bobDuration),
            SKAction.moveBy(x: 0, y: -2, duration: bobDuration)
        ])
        run(SKAction.repeatForever(drift))

        let horizontalDrift = SKAction.sequence([
            SKAction.moveBy(x: 18 * driftSpeedMultiplier, y: 0, duration: 2.4 / Double(max(driftSpeedMultiplier, 0.2))),
            SKAction.moveBy(x: -18 * driftSpeedMultiplier, y: 0, duration: 2.4 / Double(max(driftSpeedMultiplier, 0.2)))
        ])
        run(SKAction.repeatForever(horizontalDrift))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var collisionRect: CGRect {
        CGRect(
            x: position.x - logWidth * 0.45,
            y: position.y - 4,
            width: logWidth * 0.9,
            height: logHeight + 12
        )
    }

    private func roundedLogPath() -> CGPath {
        CGPath(roundedRect: CGRect(x: -logWidth * 0.5, y: 0, width: logWidth, height: logHeight), cornerWidth: 10, cornerHeight: 10, transform: nil)
    }
}
