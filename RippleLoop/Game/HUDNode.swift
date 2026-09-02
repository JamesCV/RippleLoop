import SpriteKit

final class HUDNode: SKNode {
    private let distanceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let speedLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let impulseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let powerBarBackground = SKShapeNode(rectOf: CGSize(width: 14, height: 180), cornerRadius: 7)
    private let powerBarFill = SKShapeNode(rectOf: CGSize(width: 10, height: 4), cornerRadius: 3)
    private let resultPanel = SKNode()
    private let resultTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let resultDetail = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let retryLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    override init() {
        super.init()
        zPosition = 200
        setupDistance()
        setupPowerBar()
        setupImpulse()
        setupHint()
        setupResultPanel()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDistance(_ meters: Double) {
        distanceLabel.text = String(format: "%.1f m", meters)
    }

    func updateSpeed(_ metersPerSecond: Double, normalizedPower: CGFloat) {
        speedLabel.text = String(format: "%.1f m/s", metersPerSecond)
        let clamped = min(max(normalizedPower, 0), 1)
        let height = 160 * clamped + 8
        powerBarFill.path = CGPath(
            roundedRect: CGRect(x: -5, y: -height * 0.5, width: 10, height: height),
            cornerWidth: 3,
            cornerHeight: 3,
            transform: nil
        )
    }

    func updateImpulse(remaining: Int, maxImpulses: Int) {
        impulseLabel.text = "IMPULSE \(remaining)"
        impulseLabel.alpha = remaining > 0 ? 1 : 0.45
    }

    func setHint(_ text: String) {
        hintLabel.text = text
    }

    func showResult(_ summary: RunSummary, skipCount: Int) {
        resultPanel.isHidden = false
        resultTitle.text = summary.isNewBest ? "New Best!" : "Run Complete"
        resultDetail.text = String(
            format: "%.1f m  •  %d skips  •  best %.1f m",
            summary.distanceMeters,
            skipCount,
            summary.bestDistanceMeters
        )
    }

    func hideResult() {
        resultPanel.isHidden = true
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

    private func setupImpulse() {
        impulseLabel.fontSize = 15
        impulseLabel.fontColor = SKColor.white.withAlphaComponent(0.92)
        impulseLabel.horizontalAlignmentMode = .right
        impulseLabel.verticalAlignmentMode = .top
        impulseLabel.position = CGPoint(x: -24, y: -24)
        addChild(impulseLabel)
    }

    private func setupHint() {
        hintLabel.fontSize = 15
        hintLabel.fontColor = SKColor.white.withAlphaComponent(0.75)
        hintLabel.horizontalAlignmentMode = .left
        hintLabel.position = CGPoint(x: 24, y: -760)
        hintLabel.text = "Swipe to aim and throw"
        addChild(hintLabel)
    }

    private func setupResultPanel() {
        resultPanel.isHidden = true

        let backdrop = SKShapeNode(rectOf: CGSize(width: 320, height: 180), cornerRadius: 18)
        backdrop.fillColor = SKColor.black.withAlphaComponent(0.45)
        backdrop.strokeColor = SKColor.white.withAlphaComponent(0.25)
        backdrop.lineWidth = 1
        backdrop.position = CGPoint(x: 0, y: -360)
        resultPanel.addChild(backdrop)

        resultTitle.fontSize = 28
        resultTitle.fontColor = .white
        resultTitle.position = CGPoint(x: 0, y: -320)
        resultPanel.addChild(resultTitle)

        resultDetail.fontSize = 17
        resultDetail.fontColor = SKColor.white.withAlphaComponent(0.9)
        resultDetail.position = CGPoint(x: 0, y: -360)
        resultPanel.addChild(resultDetail)

        retryLabel.fontSize = 18
        retryLabel.fontColor = SKColor.hex("#9BE7A8")
        retryLabel.text = "Tap to skip again"
        retryLabel.position = CGPoint(x: 0, y: -410)
        resultPanel.addChild(retryLabel)

        addChild(resultPanel)
    }
}