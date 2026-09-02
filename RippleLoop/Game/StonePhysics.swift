import CoreGraphics

enum StonePhysics {
    static func speed(_ velocity: CGVector) -> CGFloat {
        hypot(velocity.dx, velocity.dy)
    }

    static func launchVelocity(power: CGFloat, angleRadians: CGFloat) -> CGVector {
        let clampedPower = min(max(power, 0.15), 1.0)
        let launchSpeed = 280 + clampedPower * 520
        return CGVector(
            dx: cos(angleRadians) * launchSpeed,
            dy: sin(angleRadians) * launchSpeed
        )
    }

    static func integrate(
        position: inout CGPoint,
        velocity: inout CGVector,
        deltaTime: CGFloat
    ) {
        velocity.dy -= GameConstants.gravity * deltaTime
        velocity.dx *= GameConstants.airDrag
        velocity.dy *= GameConstants.airDrag

        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
    }

    static func attemptSkip(
        velocity: inout CGVector,
        at position: inout CGPoint
    ) -> Bool {
        let currentSpeed = speed(velocity)
        guard currentSpeed >= GameConstants.minSkipSpeed else { return false }

        let entryAngle = atan2(abs(velocity.dy), max(abs(velocity.dx), 0.001))
        guard entryAngle <= GameConstants.maxSkipEntryAngle else { return false }

        velocity.dy = abs(velocity.dy) * GameConstants.skipVerticalBoost
        velocity.dx *= GameConstants.skipHorizontalRetention
        position.y = GameConstants.waterSurfaceY + 2
        return true
    }

    static func applyImpulse(velocity: inout CGVector) {
        let currentSpeed = speed(velocity)
        guard currentSpeed > 40 else { return }

        let direction = CGVector(
            dx: velocity.dx / currentSpeed,
            dy: velocity.dy / currentSpeed
        )
        let boosted = currentSpeed + GameConstants.impulseBoostSpeed
        velocity = CGVector(dx: direction.dx * boosted, dy: direction.dy * boosted)
    }
}