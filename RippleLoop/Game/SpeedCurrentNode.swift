import SpriteKit

final class SpeedCurrentNode: SKNode {
    var collected = false

    override init() {
        super.init()
        zPosition = 14

        let glow = SKShapeNode(circleOfRadius: 22)
        glow.fillColor = SKColor.hex("#FFD878", alpha: 0.25)
        glow.strokeColor = .clear
        addChild(glow)

        let core = SKShapeNode(circleOfRadius: 12)
        core.fillColor = SKColor.hex("#FFD878", alpha: 0.85)
        core.strokeColor = SKColor.hex("#FFF0B0", alpha: 0.9)
        core.lineWidth = 2
        core.glowWidth = 3
        addChild(core)

        let arrow = SKShapeNode(path: arrowPath())
        arrow.fillColor = SKColor.white.withAlphaComponent(0.9)
        arrow.strokeColor = .clear
        addChild(arrow)

        position = CGPoint(x: 0, y: GameConstants.waterSurfaceY + 88)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.7),
            SKAction.scale(to: 1.0, duration: 0.7)
        ])
        run(SKAction.repeatForever(pulse))
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
                SKAction.scale(to: 1.8, duration: 0.18),
                SKAction.fadeOut(withDuration: 0.18)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    private func arrowPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -6, y: -2))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: -6, y: 2))
        path.closeSubpath()
        return path
    }
}
