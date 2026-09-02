import SpriteKit

final class HUDNode: SKNode {
    private let distanceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let speedLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let pearlLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let biomeLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let powerBarBackground = SKShapeNode(rectOf: CGSize(width: 14, height: 180), cornerRadius: 7)
    private let powerBarFill = SKShapeNode(rectOf: CGSize(width: 10, height: 4), cornerRadius: 3)
    private let bounceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    override init() {
        super.init()
        zPosition = 200
        setupDistance()
        setupPowerBar()
        setupCombo()
        setupPearls()
        setupBiome()
        setupHint()
        setupBounceIndicator()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDistance(_ meters: Double) {
        distanceLabel.text = String(format: "%.0f m", meters)
    }

    func updateSpeed(_ metersPerSecond: Double, normalizedPower: CGFloat) {
        speedLabel.text = String(format: "%.0f m/s", metersPerSecond)
        let clamped = min(max(normalizedPower, 0), 1)
        let height = 160 * clamped + 8
        powerBarFill.path = CGPath(
            roundedRect: CGRect(x: -5, y: -height * 0.5, width: 10, height: height),
            cornerWidth: 3,
            cornerHeight: 3,
            transform: nil
        )
    }

    func updateCombo(_ multiplier: Int) {
        if multiplier <= 1 {
            comboLabel.text = ""
        } else {
            comboLabel.text = "×\(multiplier)"
            comboLabel.alpha = min(1, 0.6 + CGFloat(multiplier) * 0.08)
        }
    }

    func updatePearls(_ count: Int) {
        pearlLabel.text = "◦ \(count)"
    }

    func updateBiome(_ name: String) {
        biomeLabel.text = name
    }

    func updateBounces(remaining: Int, max: Int) {
        bounceLabel.text = remaining > 0 ? "bounce \(remaining)" : ""
        bounceLabel.alpha = remaining > 0 ? 1 : 0.35
    }

    func setHint(_ text: String) {
        hintLabel.text = text
    }

    func flashCombo() {
        comboLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.12)
        ]))
    }

    private func setupDistance() {
        distanceLabel.fontSize = 28
        distanceLabel.fontColor = SKColor.white.withAlphaComponent(0.95)
        distanceLabel.horizontalAlignmentMode = .left
        distanceLabel.verticalAlignmentMode = .top
        distanceLabel.position = CGPoint(x: 24, y: -24)
        addChild(distanceLabel)
    }

    private func setupPowerBar() {
        powerBarBackground.fillColor = SKColor.black.withAlphaComponent(0.18)
        powerBarBackground.strokeColor = SKColor.white.withAlphaComponent(0.25)
        powerBarBackground.lineWidth = 1
        powerBarBackground.position = CGPoint(x: 28, y: -260)
        addChild(powerBarBackground)

        powerBarFill.fillColor = SKColor.hex("#7CE089")
        powerBarFill.strokeColor = .clear
        powerBarFill.position = CGPoint(x: 28, y: -260)
        addChild(powerBarFill)

        speedLabel.fontSize = 16
        speedLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        speedLabel.horizontalAlignmentMode = .left
        speedLabel.position = CGPoint(x: 44, y: -350)
        addChild(speedLabel)
    }

    private func setupCombo() {
        comboLabel.fontSize = 34
        comboLabel.fontColor = SKColor.hex("#FFD878")
        comboLabel.horizontalAlignmentMode = .center
        comboLabel.position = CGPoint(x: 195, y: -80)
        addChild(comboLabel)
    }

    private func setupPearls() {
        pearlLabel.fontSize = 18
        pearlLabel.fontColor = SKColor.hex("#E8F4FF")
        pearlLabel.horizontalAlignmentMode = .right
        pearlLabel.position = CGPoint(x: -24, y: -56)
        addChild(pearlLabel)
    }

    private func setupBiome() {
        biomeLabel.fontSize = 13
        biomeLabel.fontColor = SKColor.white.withAlphaComponent(0.55)
        biomeLabel.horizontalAlignmentMode = .left
        biomeLabel.position = CGPoint(x: 24, y: -56)
        addChild(biomeLabel)
    }

    private func setupHint() {
        hintLabel.fontSize = 15
        hintLabel.fontColor = SKColor.white.withAlphaComponent(0.75)
        hintLabel.horizontalAlignmentMode = .center
        hintLabel.position = CGPoint(x: 195, y: -760)
        hintLabel.text = "Hold to rise · Double-tap to bounce"
        addChild(hintLabel)
    }

    private func setupBounceIndicator() {
        bounceLabel.fontSize = 13
        bounceLabel.fontColor = SKColor.hex("#9BE7A8")
        bounceLabel.horizontalAlignmentMode = .right
        bounceLabel.position = CGPoint(x: -24, y: -24)
        addChild(bounceLabel)
    }
}
