import SpriteKit

protocol GameSceneHost: AnyObject {
    func gameSceneDidRequestLastRipple(_ state: ContinueState)
    func gameSceneDidFinish(_ summary: RunSummary)
}

final class GameScene: SKScene {
    weak var host: GameSceneHost?

    private var backgroundRoot = SKNode()
    private let worldNode = SKNode()
    private let obstacleNode = SKNode()
    private let stoneNode = SKShapeNode(ellipseOf: CGSize(width: 28, height: 16))
    private let pebble = PebbleNode()
    private let hud = HUDNode()
    private let aimOverlay = AimOverlay()
    private var worldSpawner: WorldSpawner!

    private var phase: RunPhase = .throwing
    private var stonePosition = CGPoint(x: GameConstants.launchX, y: GameConstants.waterSurfaceY + 18)
    private var stoneVelocity = CGVector.zero
    private var skipCount = 0
    private var runStartX: CGFloat = 0
    private var distanceMeters: Double = 0
    private var isDraggingSlider = false
    private var lastUpdateTime: TimeInterval?
    private var currentBiome: Biome = .goldenHour

    private var comboMultiplier = 1
    private var comboPeak = 1
    private var lastSkipTime: TimeInterval = 0
    private var pearlsCollected = 0
    private var lastPearlCount = 0
    private var isFirstSkipOfRun = true

    private var isHoldingBounce = false
    private var doubleBouncesRemaining = 0
    private var lastTapTime: TimeInterval = 0
    private var inAirSegment = true
    private var slowMoUntil: TimeInterval = 0

    private var sinkStartedAt: TimeInterval?
    private var hasOfferedContinue = false
    private var continuesUsed = 0

    private var runModifiers = RunItemModifiers()
    private var rippleBoostsRemaining = 0
    private var maxRippleBoosts = 0
    private var lastBoostTime: TimeInterval = 0
    private var lastMistVeilDistance: Double = 0

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = SKColor.hex(GameConstants.skyBottom)
        scaleMode = .resizeFill

        backgroundRoot = ParallaxBackground.build(in: self, biome: currentBiome)
        addChild(backgroundRoot)

        worldNode.position = .zero
        addChild(worldNode)

        obstacleNode.zPosition = 10
        worldNode.addChild(obstacleNode)
        worldSpawner = WorldSpawner(container: obstacleNode)

        stoneNode.fillColor = SKColor(white: 0.82, alpha: 1)
        stoneNode.strokeColor = SKColor(white: 0.55, alpha: 0.8)
        stoneNode.lineWidth = 1.5
        stoneNode.zPosition = 20
        worldNode.addChild(stoneNode)

        pebble.playIdle(on: CGPoint(x: GameConstants.launchX - 8, y: GameConstants.dockY))
        addChild(pebble)

        hud.position = CGPoint(x: 0, y: size.height)
        addChild(hud)

        aimOverlay.position = CGPoint(x: size.width, y: size.height)
        addChild(aimOverlay)

        beginRun()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        hud.position = CGPoint(x: 0, y: size.height)
        aimOverlay.position = CGPoint(x: size.width, y: size.height)
    }

    func useRippleBoostFromButton() {
        useRippleBoost()
    }

    func beginRun() {
        PlayerProgress.shared.resetRunState()
        PlayerProgress.shared.grantFTUERipplesIfNeeded()
        runModifiers = PlayerProgress.shared.consumeEquippedItemsIfNeeded()
        resetRun()
        startThrowSequence()
    }

    func resumeFromContinue() {
        phase = .flying
        sinkStartedAt = nil
        hasOfferedContinue = false
        continuesUsed += 1
        stoneVelocity = CGVector(dx: max(stoneVelocity.dx, 180), dy: 280)
        stonePosition.y = max(stonePosition.y, GameConstants.waterSurfaceY + 40)
        inAirSegment = true
        doubleBouncesRemaining = PlayerProgress.shared.doubleBouncesPerSegment
        let ripple = RippleEffect(at: CGPoint(x: stonePosition.x, y: GameConstants.waterSurfaceY), strength: 1.2, twin: true)
        worldNode.addChild(ripple)
        hud.setHint("Hold to rise · tap BOOST for speed")
    }

    override func update(_ currentTime: TimeInterval) {
        switch phase {
        case .flying:
            updateFlying(currentTime: currentTime)
        case .sinking:
            updateSinking(currentTime: currentTime)
        default:
            lastUpdateTime = currentTime
        }
        updateHUDValues()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch phase {
        case .aiming:
            if aimOverlay.isAngleSliderTouch(location, in: size) {
                isDraggingSlider = true
                aimOverlay.updateAngleSlider(at: location, in: size)
            } else {
                aimOverlay.resetSwipe()
                aimOverlay.appendSwipePoint(convertToAimPoint(location))
            }
        case .flying:
            handleBounceInput(at: CACurrentMediaTime())
            isHoldingBounce = true
        default:
            break
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
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingBounce = false
        guard phase == .aiming else { return }
        isDraggingSlider = false
        launchStone()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingBounce = false
        touchesEnded(touches, with: event)
    }

    private func startThrowSequence() {
        phase = .throwing
        aimOverlay.isHidden = true
        hud.setHint("Pebble prepares to throw…")
        pebble.playIdle(on: CGPoint(x: GameConstants.launchX - 8, y: GameConstants.dockY))
        pebble.playThrow(from: CGPoint(x: GameConstants.launchX - 8, y: GameConstants.dockY)) { [weak self] in
            self?.enterAiming()
        }
    }

    private func enterAiming() {
        phase = .aiming
        aimOverlay.isHidden = false
        let progress = PlayerProgress.shared
        aimOverlay.configureArcPreview(
            steps: progress.angleArcPreviewSteps,
            launchPowerBonus: progress.launchPowerBonus
        )
        hud.setHint("Swipe to aim · Pebble throws")
    }

    private func launchStone() {
        phase = .flying
        inAirSegment = true
        isFirstSkipOfRun = true
        doubleBouncesRemaining = PlayerProgress.shared.doubleBouncesPerSegment
        stoneVelocity = StonePhysics.launchVelocity(
            power: aimOverlay.swipePower,
            angleRadians: aimOverlay.launchAngle,
            powerBonus: PlayerProgress.shared.launchPowerBonus
        )
        stoneVelocity.dx *= runModifiers.launchSpeedMultiplier
        stoneVelocity.dy *= runModifiers.launchSpeedMultiplier
        stoneNode.position = stonePosition
        aimOverlay.isHidden = true
        pebble.showSpirit(at: CGPoint(x: GameConstants.launchX, y: GameConstants.dockY + 20))
        hud.setHint("Hold to rise · tap BOOST for speed")
        aimOverlay.resetSwipe()
        HapticManager.launch()
        SoundManager.shared.playLaunch()
        updateBoostHUD()
    }

    private func handleBounceInput(at time: TimeInterval) {
        guard phase == .flying else { return }

        if time - lastTapTime <= GameConstants.doubleBounceWindow, doubleBouncesRemaining > 0 {
            doubleBouncesRemaining -= 1
            StonePhysics.applyDoubleBounce(velocity: &stoneVelocity)
            slowMoUntil = time + GameConstants.slowMoDuration
            let ripple = RippleEffect(
                at: CGPoint(x: stonePosition.x, y: stonePosition.y),
                strength: 1.0,
                twin: true
            )
            worldNode.addChild(ripple)
            hud.flashCombo()
            HapticManager.doubleBounce()
            SoundManager.shared.playDoubleBounce()
        } else {
            StonePhysics.applyBounce(velocity: &stoneVelocity, holding: false)
            let ripple = RippleEffect(
                at: CGPoint(x: stonePosition.x, y: stonePosition.y - 8),
                strength: 0.6
            )
            worldNode.addChild(ripple)
            HapticManager.bounce()
            SoundManager.shared.playBounce()
        }
        lastTapTime = time
        updateBounceHUD()
    }

    private func updateFlying(currentTime: TimeInterval) {
        let delta = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime
        var deltaTime = CGFloat(min(max(delta, 0), 1.0 / 30.0))
        if currentTime < slowMoUntil {
            deltaTime *= GameConstants.slowMoFactor
        }
        guard deltaTime > 0 else { return }

        if isHoldingBounce {
            StonePhysics.applyBounce(
                velocity: &stoneVelocity,
                holding: true,
                holdLiftMultiplier: PlayerProgress.shared.holdLiftMultiplier
            )
        }

        let gravityMultiplier = PlayerProgress.shared.bounceFloatFactor
        StonePhysics.integrate(
            position: &stonePosition,
            velocity: &stoneVelocity,
            deltaTime: deltaTime,
            gravityMultiplier: gravityMultiplier
        )

        if worldSpawner.checkLogCollision(stonePosition: stonePosition, stoneRadius: 14) {
            beginSinking(at: currentTime, reason: .obstacle)
            return
        }

        let magnet = PlayerProgress.shared.pearlMagnetRadius
        pearlsCollected += worldSpawner.collectPearls(near: stonePosition, magnetRadius: magnet)
        if pearlsCollected > lastPearlCount {
            let gained = pearlsCollected - lastPearlCount
            lastPearlCount = pearlsCollected
            for _ in 0..<gained {
                HapticManager.pearl()
                SoundManager.shared.playPearl()
            }
        }

        let currentsCollected = worldSpawner.collectSpeedCurrents(near: stonePosition)
        if currentsCollected > 0 {
            for _ in 0..<currentsCollected {
                StonePhysics.applySpeedCurrent(velocity: &stoneVelocity)
                rippleBoostsRemaining = min(rippleBoostsRemaining + 1, maxRippleBoosts + 2)
                if runModifiers.currentRiderRemaining > 0 {
                    runModifiers.currentRiderRemaining -= 1
                    rippleBoostsRemaining = min(rippleBoostsRemaining + 2, maxRippleBoosts + 4)
                }
                HapticManager.doubleBounce()
                SoundManager.shared.playBoost()
            }
            updateBoostHUD()
        }

        if stonePosition.y <= GameConstants.waterSurfaceY && stoneVelocity.dy < 0 {
            inAirSegment = false
            let progress = PlayerProgress.shared
            var retentionBonus = progress.skipSpeedRetentionBonus
            if isFirstSkipOfRun {
                retentionBonus += progress.dockFootingRetentionBonus
            }

            let didSkip = StonePhysics.attemptSkip(
                velocity: &stoneVelocity,
                at: &stonePosition,
                angleBonus: progress.skipAngleBonus + runModifiers.extraSkipForgiveness,
                retentionBonus: retentionBonus,
                minSpeedReduction: progress.deepSkimMinSpeedReduction
            )

            if didSkip {
                skipCount += 1
                isFirstSkipOfRun = false
                registerSkip(at: currentTime)
                inAirSegment = true
                doubleBouncesRemaining = PlayerProgress.shared.doubleBouncesPerSegment
                let ripple = RippleEffect(
                    at: CGPoint(x: stonePosition.x, y: GameConstants.waterSurfaceY),
                    strength: StonePhysics.speed(stoneVelocity) / 400
                )
                worldNode.addChild(ripple)
            } else if attemptSoftLandingRecovery() {
                skipCount += 1
                isFirstSkipOfRun = false
                registerSkip(at: currentTime)
                inAirSegment = true
                doubleBouncesRemaining = PlayerProgress.shared.doubleBouncesPerSegment
                let ripple = RippleEffect(
                    at: CGPoint(x: stonePosition.x, y: GameConstants.waterSurfaceY),
                    strength: 0.7
                )
                worldNode.addChild(ripple)
            } else {
                beginSinking(at: currentTime, reason: .failedSkip)
            }
        }

        if stonePosition.y < -80 {
            beginSinking(at: currentTime, reason: .outOfBounds)
        }

        stoneNode.position = stonePosition
        updateCamera()
        updateMistVeilProgress()
        updateBiomeIfNeeded()
        updateSpawnConfig()
        worldSpawner.update(stoneX: stonePosition.x, distanceMeters: distanceMeters)
        updateBounceHUD()
    }

    private enum SinkReason {
        case failedSkip, obstacle, outOfBounds
    }

    private func attemptSoftLandingRecovery() -> Bool {
        guard runModifiers.softLandingAvailable, !runModifiers.softLandingUsed else { return false }
        runModifiers.softLandingUsed = true

        let progress = PlayerProgress.shared
        stoneVelocity.dy = abs(stoneVelocity.dy) * 0.55
        stoneVelocity.dx *= 0.92 + progress.skipSpeedRetentionBonus
        stonePosition.y = GameConstants.waterSurfaceY + 2
        hud.flashCombo()
        HapticManager.skip(combo: comboMultiplier)
        SoundManager.shared.playSkip(combo: comboMultiplier)
        return stoneVelocity.dx > 60
    }

    private func beginSinking(at time: TimeInterval, reason: SinkReason) {
        guard phase == .flying else { return }
        phase = .sinking
        sinkStartedAt = time
        stoneVelocity = CGVector(dx: stoneVelocity.dx * 0.3, dy: -60)
        hud.setHint("")
        HapticManager.sink()
        SoundManager.shared.playSink()
        _ = reason
    }

    private func updateSinking(currentTime: TimeInterval) {
        guard let started = sinkStartedAt else { return }
        let delta = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime
        let deltaTime = CGFloat(min(max(delta, 0), 1.0 / 30.0))

        stoneVelocity.dy -= 120 * deltaTime
        stonePosition.x += stoneVelocity.dx * deltaTime
        stonePosition.y += stoneVelocity.dy * deltaTime
        stoneNode.position = stonePosition
        stoneNode.alpha = max(0.2, 1 - CGFloat(currentTime - started) / 1.4)
        updateCamera()

        if currentTime - started >= GameConstants.sinkDuration {
            offerContinueOrFinish()
        }
    }

    private func offerContinueOrFinish() {
        guard phase == .sinking else { return }

        if !hasOfferedContinue && continuesUsed == 0 {
            hasOfferedContinue = true
            phase = .finished
            let state = ContinueState(
                distanceMeters: distanceMeters,
                skipCount: skipCount,
                comboMultiplier: comboMultiplier,
                pearlsCollected: pearlsCollected,
                canContinue: true
            )
            host?.gameSceneDidRequestLastRipple(state)
        } else {
            finishRun()
        }
    }

    private func finishRun() {
        phase = .finished
        stoneVelocity = .zero

        distanceMeters = max(0, Double(stonePosition.x - runStartX) * Double(GameConstants.metersPerPoint))
        let summary = PlayerProgress.shared.recordRun(
            distanceMeters: distanceMeters,
            skipCount: skipCount,
            pearlsCollected: pearlsCollected,
            comboPeak: comboPeak,
            biome: currentBiome,
            pearlRippleMultiplier: runModifiers.pearlRippleMultiplier
        )
        host?.gameSceneDidFinish(summary)
    }

    private func useRippleBoost() {
        guard phase == .flying else { return }
        guard rippleBoostsRemaining > 0 else { return }

        let now = CACurrentMediaTime()
        let progress = PlayerProgress.shared
        var cooldown = GameConstants.rippleBoostCooldown * runModifiers.boostCooldownMultiplier
        let speed = StonePhysics.speed(stoneVelocity) * GameConstants.metersPerPoint * 60
        if speed < 180 {
            cooldown *= max(0.35, 1 - progress.overdriveCooldownBonus)
        }
        guard now - lastBoostTime >= cooldown else { return }

        rippleBoostsRemaining -= 1
        lastBoostTime = now
        StonePhysics.applyRippleBoost(
            velocity: &stoneVelocity,
            strength: progress.rippleBoostStrength,
            combo: comboMultiplier
        )
        let ripple = RippleEffect(
            at: CGPoint(x: stonePosition.x, y: stonePosition.y),
            strength: 1.1,
            twin: true
        )
        worldNode.addChild(ripple)
        hud.flashBoost()
        updateBoostHUD()
        HapticManager.doubleBounce()
        SoundManager.shared.playBoost()
    }

    private func registerSkip(at time: TimeInterval) {
        let comboWindow = GameConstants.comboWindowSeconds + PlayerProgress.shared.comboWindowBonus
        if time - lastSkipTime <= comboWindow {
            comboMultiplier = min(comboMultiplier + 1, 10)
        } else {
            comboMultiplier = 1
        }

        if runModifiers.momentumSeedActive && !runModifiers.momentumSeedUsed {
            runModifiers.momentumSeedUsed = true
            comboMultiplier = max(comboMultiplier, 3)
            StonePhysics.applyRippleBoost(
                velocity: &stoneVelocity,
                strength: 1.4,
                combo: comboMultiplier
            )
        }

        comboPeak = max(comboPeak, comboMultiplier)
        lastSkipTime = time
        StonePhysics.applyComboMomentum(
            velocity: &stoneVelocity,
            combo: comboMultiplier,
            factor: PlayerProgress.shared.comboMomentumFactor
        )
        hud.updateCombo(comboMultiplier)
        hud.flashCombo()
        HapticManager.skip(combo: comboMultiplier)
        SoundManager.shared.playSkip(combo: comboMultiplier)
    }

    private func updateBiomeIfNeeded() {
        let goldenHourExtension = runModifiers.morningDewActive ? 200.0 : 0
        let biome = Biome.forDistance(distanceMeters, goldenHourExtensionMeters: goldenHourExtension)
        guard biome != currentBiome else { return }
        currentBiome = biome
        ParallaxBackground.applyBiome(biome, to: backgroundRoot, sceneSize: size)
        backgroundColor = SKColor.hex(biome.skyBottom)
        hud.updateBiome(biome.displayName)
        HapticManager.biomeShift()
        SoundManager.shared.playBiomeShift()
    }

    private func updateMistVeilProgress() {
        guard runModifiers.mistVeilActive else { return }
        let delta = max(0, distanceMeters - lastMistVeilDistance)
        lastMistVeilDistance = distanceMeters
        runModifiers.mistVeilDistanceRemaining -= delta
        if runModifiers.mistVeilDistanceRemaining <= 0 {
            runModifiers.mistVeilActive = false
        }
    }

    private func updateSpawnConfig() {
        let progress = PlayerProgress.shared
        let finderBonus = 1 + Double(progress.rippleFinderSpawnBonus)

        var logSpawnMultiplier = 1.0
        if runModifiers.mistVeilActive {
            logSpawnMultiplier = 0.45
        }

        worldSpawner.configure(
            WorldSpawnConfig(
                pearlSpawnMultiplier: finderBonus,
                currentSpawnMultiplier: finderBonus,
                logSpawnMultiplier: logSpawnMultiplier,
                logDriftSpeedMultiplier: runModifiers.logSpeedMultiplier
            )
        )
    }

    private func resetRun() {
        phase = .throwing
        stonePosition = CGPoint(x: GameConstants.launchX, y: GameConstants.waterSurfaceY + 18)
        stoneVelocity = .zero
        skipCount = 0
        runStartX = stonePosition.x
        distanceMeters = 0
        comboMultiplier = max(1, runModifiers.startingCombo)
        comboPeak = comboMultiplier
        pearlsCollected = 0
        lastPearlCount = 0
        isFirstSkipOfRun = true
        currentBiome = .goldenHour
        hasOfferedContinue = false
        continuesUsed = 0
        sinkStartedAt = nil
        stoneNode.alpha = 1
        inAirSegment = true
        doubleBouncesRemaining = PlayerProgress.shared.doubleBouncesPerSegment
        maxRippleBoosts = PlayerProgress.shared.rippleBoostsPerRun + runModifiers.extraBoostCharges
        rippleBoostsRemaining = maxRippleBoosts
        lastBoostTime = 0
        lastSkipTime = 0
        lastMistVeilDistance = 0

        worldNode.position = .zero
        obstacleNode.removeAllChildren()
        worldSpawner.reset()
        updateSpawnConfig()
        backgroundRoot.removeFromParent()
        backgroundRoot = ParallaxBackground.build(in: self, biome: currentBiome)
        insertChild(backgroundRoot, at: 0)

        stoneNode.position = stonePosition
        aimOverlay.resetSwipe()
        aimOverlay.isHidden = true
        hud.updateCombo(comboMultiplier)
        hud.updatePearls(0)
        hud.updateBiome(currentBiome.displayName)
        updateBounceHUD()
        updateBoostHUD()
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
        hud.updatePearls(pearlsCollected)
        updateBoostHUD()
    }

    private func updateBounceHUD() {
        hud.updateBounces(remaining: doubleBouncesRemaining, max: PlayerProgress.shared.doubleBouncesPerSegment)
    }

    private func updateBoostHUD() {
        let speed = StonePhysics.speed(stoneVelocity) * GameConstants.metersPerPoint * 60
        hud.updateBoosts(remaining: rippleBoostsRemaining, max: maxRippleBoosts, speed: Double(speed))
    }

    private func convertToAimPoint(_ location: CGPoint) -> CGPoint {
        CGPoint(x: location.x - size.width + 24, y: location.y - 120)
    }
}
