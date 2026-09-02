import SpriteKit

extension SKColor {
    static func hex(_ hex: String, alpha: CGFloat = 1) -> SKColor {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >> 8) / 255
        let b = CGFloat(value & 0x0000FF) / 255
        return SKColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

enum ParallaxBackground {
    static func build(in scene: SKScene) -> SKNode {
        let root = SKNode()
        root.zPosition = -100

        let skyHeight = scene.size.height
        let skySteps = 12
        for index in 0..<skySteps {
            let t = CGFloat(index) / CGFloat(skySteps - 1)
            let top = SKColor.hex(GameConstants.skyTop)
            let bottom = SKColor.hex(GameConstants.skyBottom)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            top.getRed(&r, green: &g, blue: &b, alpha: &a)
            var r2: CGFloat = 0
            var g2: CGFloat = 0
            var b2: CGFloat = 0
            var a2: CGFloat = 0
            bottom.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

            let band = SKSpriteNode(
                color: SKColor(
                    red: r + (r2 - r) * t,
                    green: g + (g2 - g) * t,
                    blue: b + (b2 - b) * t,
                    alpha: 1
                ),
                size: CGSize(width: scene.size.width * 4, height: skyHeight / CGFloat(skySteps) + 2)
            )
            band.position = CGPoint(x: scene.size.width * 0.5, y: skyHeight - band.size.height * (CGFloat(index) + 0.5))
            band.zPosition = -30
            root.addChild(band)
        }

        let farLayer = SKNode()
        farLayer.name = "farLayer"
        farLayer.zPosition = -20
        for index in 0..<8 {
            let rock = makeRock(width: CGFloat.random(in: 120...220), height: CGFloat.random(in: 70...140))
            rock.position = CGPoint(x: CGFloat(index) * 280 + 40, y: GameConstants.waterSurfaceY + 90)
            farLayer.addChild(rock)
        }
        root.addChild(farLayer)

        let midLayer = SKNode()
        midLayer.name = "midLayer"
        midLayer.zPosition = -10
        for index in 0..<6 {
            let island = makeIsland()
            island.position = CGPoint(x: CGFloat(index) * 420 + 180, y: GameConstants.waterSurfaceY + 24)
            midLayer.addChild(island)
        }
        root.addChild(midLayer)

        let water = SKSpriteNode(
            color: SKColor.hex(GameConstants.waterDeep),
            size: CGSize(width: scene.size.width * 8, height: 260)
        )
        water.anchorPoint = CGPoint(x: 0.5, y: 0)
        water.position = CGPoint(x: scene.size.width * 0.5, y: 0)
        water.zPosition = -5
        water.name = "water"
        root.addChild(water)

        let shimmer = SKSpriteNode(
            color: SKColor.hex(GameConstants.waterShallow, alpha: 0.35),
            size: CGSize(width: scene.size.width * 8, height: 36)
        )
        shimmer.anchorPoint = CGPoint(x: 0.5, y: 0)
        shimmer.position = CGPoint(x: scene.size.width * 0.5, y: GameConstants.waterSurfaceY - 8)
        shimmer.zPosition = -4
        root.addChild(shimmer)

        return root
    }

    private static func makeRock(width: CGFloat, height: CGFloat) -> SKNode {
        let node = SKShapeNode(path: roundedRect(width: width, height: height, radius: height * 0.35))
        node.fillColor = SKColor.hex(GameConstants.rockTan)
        node.strokeColor = SKColor.hex("#A88458", alpha: 0.5)
        node.lineWidth = 2
        return node
    }

    private static func makeIsland() -> SKNode {
        let island = SKNode()
        let base = SKShapeNode(ellipseOf: CGSize(width: 140, height: 44))
        base.fillColor = SKColor.hex(GameConstants.grassGreen)
        base.strokeColor = SKColor.hex("#4A9154", alpha: 0.6)
        base.lineWidth = 1.5
        island.addChild(base)

        for index in 0..<3 {
            let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 28), cornerRadius: 2)
            trunk.fillColor = SKColor.hex("#8B5A2B")
            trunk.strokeColor = .clear
            trunk.position = CGPoint(x: CGFloat(index - 1) * 26, y: 24)
            island.addChild(trunk)

            let leaves = SKShapeNode(circleOfRadius: 16)
            leaves.fillColor = SKColor.hex("#4FAF63")
            leaves.strokeColor = .clear
            leaves.position = CGPoint(x: CGFloat(index - 1) * 26, y: 42)
            island.addChild(leaves)
        }
        return island
    }

    private static func roundedRect(width: CGFloat, height: CGFloat, radius: CGFloat) -> CGPath {
        let rect = CGRect(x: -width * 0.5, y: 0, width: width, height: height)
        return CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    }
}