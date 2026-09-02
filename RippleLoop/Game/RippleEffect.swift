import SpriteKit

final class RippleEffect: SKNode {
    init(at position: CGPoint, strength: CGFloat, twin: Bool = false) {
        super.init()
        self.position = position
        zPosition = 5

        let ringCount = twin ? 4 : 3
        for index in 0..<ringCount {
            let ring = SKShapeNode(circleOfRadius: 8 + CGFloat(index) * 4)
            let alpha = twin ? 0.65 - CGFloat(index) * 0.1 : 0.55 - CGFloat(index) * 0.12
            ring.strokeColor = twin
                ? SKColor.hex("#FFD878", alpha: alpha)
                : SKColor.white.withAlphaComponent(alpha)
            ring.fillColor = .clear
            ring.lineWidth = twin ? 2.5 : 2
            ring.setScale(0.2 + strength * 0.15)
            addChild(ring)

            let grow = SKAction.group([
                SKAction.scale(to: (twin ? 2.8 : 2.2) + strength * 0.25, duration: twin ? 0.85 : 0.7),
                SKAction.fadeOut(withDuration: twin ? 0.85 : 0.7)
            ])
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * (twin ? 0.05 : 0.08)),
                grow,
                SKAction.removeFromParent()
            ]))
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: twin ? 1.2 : 1.0),
            SKAction.removeFromParent()
        ]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
