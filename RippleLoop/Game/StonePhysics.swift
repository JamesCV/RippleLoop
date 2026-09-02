import CoreGraphics

enum StonePhysics {
    static func speed(_ velocity: CGVector) -> CGFloat {
        hypot(velocity.dx, velocity.dy)
    }

    static func launchVelocity(power: CGFloat, angleRadians: CGFloat, powerBonus: CGFloat = 0) -> CGVector {
        let clampedPower = min(max(power, 0.15), 1.0)
        let launchSpeed = (280 + clampedPower * 520) * (1 + powerBonus)
        return CGVector(
            dx: cos(angleRadians) * launchSpeed,
            dy: sin(angleRadians) * launchSpeed
        )
    }

    static func integrate(
        position: inout CGPoint,
        velocity: inout CGVector,
        deltaTime: CGFloat,
        gravityMultiplier: CGFloat = 1
    ) {
        velocity.dy -= GameConstants.gravity * gravityMultiplier * deltaTime
        velocity.dx *= GameConstants.airDrag
        velocity.dy *= GameConstants.airDrag

        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
    }

    static func attemptSkip(
        velocity: inout CGVector,
        at position: inout CGPoint,
        angleBonus: CGFloat = 0,
        retentionBonus: CGFloat = 0,
        minSpeedReduction: CGFloat = 0
    ) -> Bool {
        let currentSpeed = speed(velocity)
        let minSpeed = max(40, GameConstants.minSkipSpeed - minSpeedReduction)
        guard currentSpeed >= minSpeed else { return false }

        let entryAngle = atan2(abs(velocity.dy), max(abs(velocity.dx), 0.001))
        guard entryAngle <= GameConstants.maxSkipEntryAngle + angleBonus else { return false }

        velocity.dy = abs(velocity.dy) * GameConstants.skipVerticalBoost
        velocity.dx *= GameConstants.skipHorizontalRetention + retentionBonus
        position.y = GameConstants.waterSurfaceY + 2
        return true
    }

    static func applyRippleBoost(velocity: inout CGVector, strength: CGFloat, combo: Int) {
        let currentSpeed = max(speed(velocity), 60)
        let direction = CGVector(
            dx: velocity.dx / max(currentSpeed, 1),
            dy: velocity.dy / max(currentSpeed, 1)
        )
        let comboBonus = 1 + CGFloat(max(combo - 1, 0)) * 0.04
        let surge = (GameConstants.rippleBoostSpeed + currentSpeed * 0.25) * strength * comboBonus
        velocity.dx = direction.dx * (currentSpeed + surge) + 24
        velocity.dy = max(velocity.dy, 0) + GameConstants.rippleBoostLift * strength
    }

    static func applyComboMomentum(velocity: inout CGVector, combo: Int, factor: CGFloat) {
        guard combo > 1, factor > 0 else { return }
        let boost = 1 + CGFloat(combo - 1) * factor
        velocity.dx *= boost
        velocity.dy = max(velocity.dy, abs(velocity.dy) * 0.5)
    }

    static func applySpeedCurrent(velocity: inout CGVector) {
        let currentSpeed = max(speed(velocity), 80)
        velocity.dx += GameConstants.speedCurrentBurst
        velocity.dy = max(velocity.dy, 120)
        _ = currentSpeed
    }

    static func applyBounce(velocity: inout CGVector, holding: Bool, holdLiftMultiplier: CGFloat = 1) {
        let lift = GameConstants.bounceLiftForce * (holding ? GameConstants.bounceHoldMultiplier * holdLiftMultiplier : 1)
        velocity.dy = max(velocity.dy, 0) + lift
        velocity.dx += 18
    }

    static func applyDoubleBounce(velocity: inout CGVector) {
        velocity.dy = max(velocity.dy, 0) + GameConstants.doubleBounceForce
        velocity.dx += 36
    }

    static func predictedArcPoints(
        start: CGPoint,
        power: CGFloat,
        angleRadians: CGFloat,
        powerBonus: CGFloat,
        steps: Int
    ) -> [CGPoint] {
        var position = start
        var velocity = launchVelocity(power: power, angleRadians: angleRadians, powerBonus: powerBonus)
        let deltaTime: CGFloat = 0.05
        var points: [CGPoint] = [position]

        for _ in 0..<max(steps, 1) {
            integrate(position: &position, velocity: &velocity, deltaTime: deltaTime)
            points.append(position)
            if position.y <= GameConstants.waterSurfaceY {
                break
            }
        }

        return points
    }
}
