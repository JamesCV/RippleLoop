import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRequestImpulse()
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?

    private var backgroundRoot = SKNode()
    private let worldNode = SKNode()
    private let stoneNode = SKShapeNode(ellipseOf: CGSize(width: 28, height: 16))
    private let hud = HUDNode()
    private let aimOverlay = AimOverlay()

    private var phase: RunPhase = .aiming
    private var stonePosition = CGPoint(x: GameConstants.launchX, y: GameConstants.waterSurfaceY + 18)
    private var stoneVelocity = CGVector.zero
    private var skipCount = 0
    private var impulsesRemaining = 0
    private var lastImpulseTime: TimeInterval = 0
    private var runStartX: CGFloat = 0
    private var distanceMeters: Double = 0
    private var isDraggingSlider = false
    private var runSummary: RunSummary?
    private var lastUpdateTime: TimeInterval?

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = SKColor.hex(GameConstants.skyBottom)
        scaleMode = .resizeFill

        backgroundRoot = ParallaxBackground.build(in: self)
        addChild(backgroundRoot)

        worldNode.position = .zero
        addChild(worldNode)

        stoneNode.fillColor = SKColor(white: 0.82, alpha: 1)
        stoneNode.strokeColor = SKColor(white: 0.55, alpha: 0.8)
        stoneNode.lineWidth = 1.5
        stoneNode.zPosition = 20
        worldNode.addChild(stoneNode)

        hud.position = CGPoint(x: 0, y: size.height)
        addChild(hud)

        aimOverlay.position = CGPoint(x: size.width, y: size.height)
        addChild(aimOverlay)

        resetRun()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        hud.position = CGPoint(x: 0, y: size.height)
        aimOverlay.position = CGPoint(x: size.width, y: size.height)
        backgroundRoot.removeFromParent()
        backgroundRoot = ParallaxBackground.build(in: self)
        insertChild(backgroundRoot, at: 0)
    }

    override func update(_ currentTime: TimeInterval) {
        guard phase == .flying else {
            lastUpdateTime = currentTime
            return
        }

        let delta = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime
        let deltaTime = CGFloat(min(max(delta, 0), 1.0 / 30.0))
        guard deltaTime > 0 else { return }
        StonePhysics.integrate(position: &stonePosition, velocity: &stoneVelocity, deltaTime: deltaTime)

        if stonePosition.y <= GameConstants.waterSurfaceY && stoneVelocity.dy < 0 {
            if StonePhysics.attemptSkip(velocity: &stoneVelocity, at: &stonePosition) {
                skipCount += 1
                let ripple = RippleEffect(
                    at: CGPoint(x: stonePosition.x, y: GameConstants.waterSurfaceY),
                    strength: StonePhysics.speed(stoneVelocity) / 400
                )
                worldNode.addChild(ripple)
            } else {
                finishRun()
            }
        }

        if stonePosition.y < -80 {
            finishRun()
        }

        stoneNode.position = stonePosition
        updateCamera()
        updateHUDValues()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if phase == .finished {
            resetRun()
            return
        }

        if phase == .aiming {
            if aimOverlay.isAngleSliderTouch(location, in: size) {
                isDraggingSlider = true
                aimOverlay.updateAngleSlider(at: location, in: size)
            } else {
                aimOverlay.resetSwipe()
                aimOverlay.appendSwipePoint(convertToAimPoint(location))
            }
        } else if phase == .flying {
            useImpulse()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard phase == .aiming, let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isDraggingSlider || aimOverlay.isAngleSliderTouch(location, in: size) {
            isDraggingSlider = true
            aimOverlay.updateAngleSlider(at: location, in: size)
        } else {
            aimOverlay.appendSwipePoint(convertToAimPoint(location))
        }
        updateHUDValues()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard phase == .aiming else { return }
        isDraggingSlider = false
        launchStone()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    func useImpulseFromButton() {
        useImpulse()
    }

    private func resetRun() {
        phase = .aiming
        stonePosition = CGPoint(x: GameConstants.launchX, y: GameConstants.waterSurfaceY + 18)
        stoneVelocity = .zero
        skipCount = 0
        impulsesRemaining = PlayerProgress.shared.maxImpulses
        runStartX = stonePosition.x
        distanceMeters = 0
        runSummary = nil

        worldNode.position = .zero
        stoneNode.position = stonePosition
        aimOverlay.resetSwipe()
        hud.hideResult()
        hud.setHint("Swipe to aim and throw")
        updateHUDValues()
    }

    private func launchStone() {
        phase = .flying
        stoneVelocity = StonePhysics.launchVelocity(
            power: aimOverlay.swipePower,
            angleRadians: aimOverlay.launchAngle
        )
        stoneNode.position = stonePosition
        hud.setHint("Tap for IMPULSE boost")
        aimOverlay.resetSwipe()
    }

    private func useImpulse() {
        guard phase == .flying else { return }
        guard impulsesRemaining > 0 else { return }
        guard CACurrentMediaTime() - lastImpulseTime >= GameConstants.impulseCooldown else { return }

        impulsesRemaining -= 1
        lastImpulseTime = CACurrentMediaTime()
        StonePhysics.applyImpulse(velocity: &stoneVelocity)
        gameDelegate?.gameSceneDidRequestImpulse()
        updateHUDValues()
    }

    private func finishRun() {
        guard phase != .finished else { return }
        phase = .finished
        stoneVelocity = .zero

        distanceMeters = Double(stonePosition.x - runStartX) * Double(GameConstants.metersPerPoint)
        var summary = PlayerProgress.shared.recordRun(distanceMeters: distanceMeters)
        summary = RunSummary(
            distanceMeters: summary.distanceMeters,
            skipCount: skipCount,
            bestDistanceMeters: summary.bestDistanceMeters,
            isNewBest: summary.isNewBest
        )
        runSummary = summary
        hud.showResult(summary, skipCount: skipCount)
        hud.setHint("")
        updateHUDValues()
    }

    private func updateCamera() {
        let targetX = max(0, stonePosition.x - size.width * 0.28)
        worldNode.position = CGPoint(x: -targetX, y: 0)

        if let far = backgroundRoot.childNode(withName: "farLayer") {
            far.position.x = -targetX * 0.18
        }
        if let mid = backgroundRoot.childNode(withName: "midLayer") {
            mid.position.x = -targetX * 0.35
        }
    }

    private func updateHUDValues() {
        distanceMeters = max(0, Double(stonePosition.x - runStartX) * Double(GameConstants.metersPerPoint))
        hud.updateDistance(distanceMeters)

        let speed = StonePhysics.speed(stoneVelocity) * GameConstants.metersPerPoint * 60
        let power = phase == .aiming ? aimOverlay.swipePower : min(StonePhysics.speed(stoneVelocity) / 700, 1)
        hud.updateSpeed(Double(speed), normalizedPower: power)
        hud.updateImpulse(remaining: impulsesRemaining, maxImpulses: PlayerProgress.shared.maxImpulses)
    }

    private func convertToAimPoint(_ location: CGPoint) -> CGPoint {
        CGPoint(x: location.x - size.width + 24, y: location.y - 120)
    }
}