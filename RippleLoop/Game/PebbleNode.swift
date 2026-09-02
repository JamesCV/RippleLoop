import SpriteKit

final class PebbleNode: SKNode {
    private let body = SKShapeNode()
    private let hood = SKShapeNode()
    private let arm = SKShapeNode()
    private let stone = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
    private var accentNode: SKShapeNode?

    override init() {
        super.init()
        zPosition = 30

        body.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 28), cornerWidth: 6, cornerHeight: 6, transform: nil)
        body.fillColor = SKColor.hex("#3A4858")
        body.strokeColor = SKColor.hex("#2A3848", alpha: 0.6)
        body.lineWidth = 1
        addChild(body)

        hood.path = CGPath(ellipseIn: CGRect(x: -14, y: 22, width: 28, height: 18), transform: nil)
        hood.fillColor = SKColor.hex("#4A5868")
        hood.strokeColor = .clear
        addChild(hood)

        arm.path = CGPath(roundedRect: CGRect(x: 4, y: 16, width: 18, height: 5), cornerWidth: 2, cornerHeight: 2, transform: nil)
        arm.fillColor = SKColor.hex("#3A4858")
        arm.strokeColor = .clear
        arm.zRotation = -0.4
        addChild(arm)

        stone.fillColor = SKColor(white: 0.82, alpha: 1)
        stone.strokeColor = SKColor(white: 0.55, alpha: 0.8)
        stone.lineWidth = 1
        stone.position = CGPoint(x: 18, y: 20)
        stone.zRotation = -0.3
        addChild(stone)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyOutfit(_ outfit: PebbleOutfitKind) {
        body.fillColor = SKColor.hex(outfit.bodyHex)
        body.strokeColor = SKColor.hex(outfit.bodyHex, alpha: 0.7)
        hood.fillColor = SKColor.hex(outfit.hoodHex)
        arm.fillColor = SKColor.hex(outfit.bodyHex)

        accentNode?.removeFromParent()
        accentNode = nil

        if let accentHex = outfit.accentHex {
            let accent = SKShapeNode(rectOf: CGSize(width: 16, height: 4), cornerRadius: 2)
            accent.fillColor = SKColor.hex(accentHex)
            accent.strokeColor = .clear
            accent.position = CGPoint(x: -2, y: 24)
            accent.zRotation = 0.15
            addChild(accent)
            accentNode = accent
        }
    }

    func playIdle(on dockPosition: CGPoint) {
        position = dockPosition
        alpha = 1
        setScale(1)
        removeAllActions()
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.4),
            SKAction.moveBy(x: 0, y: -3, duration: 1.4)
        ])
        run(SKAction.repeatForever(bob))
    }

    func playThrow(from start: CGPoint, completion: @escaping () -> Void) {
        removeAllActions()
        position = start
        alpha = 1

        let windUp = SKAction.group([
            SKAction.moveBy(x: -6, y: 4, duration: 0.18),
            SKAction.rotate(byAngle: 0.12, duration: 0.18)
        ])
        let release = SKAction.group([
            SKAction.moveBy(x: 14, y: -2, duration: 0.22),
            SKAction.rotate(byAngle: -0.25, duration: 0.22),
            SKAction.fadeOut(withDuration: 0.35)
        ])
        run(SKAction.sequence([windUp, release, SKAction.run(completion)]))
    }

    func showSpirit(at position: CGPoint) {
        alpha = 0.35
        setScale(0.6)
        self.position = position
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.15, duration: 0.8),
            SKAction.fadeAlpha(to: 0.35, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))
    }
}
