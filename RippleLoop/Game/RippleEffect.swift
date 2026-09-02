import SpriteKit

final class RippleEffect: SKNode {
    init(at position: CGPoint, strength: CGFloat) {
        super.init()
        self.position = position
        zPosition = 5

        let ringCount = 3
        for index in 0..<ringCount {
            let ring = SKShapeNode(circleOfRadius: 8 + CGFloat(index) * 4)
            ring.strokeColor = SKColor.white.withAlphaComponent(0.55 - CGFloat(index) * 0.12)
            ring.fillColor = .clear
            ring.lineWidth = 2
            ring.setScale(0.2 + strength * 0.15)
            addChild(ring)

            let grow = SKAction.group([
                SKAction.scale(to: 2.2 + strength * 0.25, duration: 0.7),
                SKAction.fadeOut(withDuration: 0.7)
            ])
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.08),
                grow,
                SKAction.removeFromParent()
            ]))
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}