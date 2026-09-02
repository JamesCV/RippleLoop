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
        angleBonus: CGFloat = 0
    ) -> Bool {
        let currentSpeed = speed(velocity)
        guard currentSpeed >= GameConstants.minSkipSpeed else { return false }

        let entryAngle = atan2(abs(velocity.dy), max(abs(velocity.dx), 0.001))
        guard entryAngle <= GameConstants.maxSkipEntryAngle + angleBonus else { return false }

        velocity.dy = abs(velocity.dy) * GameConstants.skipVerticalBoost
        velocity.dx *= GameConstants.skipHorizontalRetention
        position.y = GameConstants.waterSurfaceY + 2
        return true
    }

    static func applyBounce(velocity: inout CGVector, holding: Bool) {
        let lift = GameConstants.bounceLiftForce * (holding ? GameConstants.bounceHoldMultiplier : 1)
        velocity.dy = max(velocity.dy, 0) + lift
        velocity.dx += 18
    }

    static func applyDoubleBounce(velocity: inout CGVector) {
        velocity.dy = max(velocity.dy, 0) + GameConstants.doubleBounceForce
        velocity.dx += 36
    }
}
