import XCTest
@testable import RippleLoop

final class StonePhysicsTests: XCTestCase {
    func testLaunchVelocityScalesWithPower() {
        let weak = StonePhysics.launchVelocity(power: 0.2, angleRadians: 0.4)
        let strong = StonePhysics.launchVelocity(power: 1.0, angleRadians: 0.4)
        XCTAssertGreaterThan(StonePhysics.speed(strong), StonePhysics.speed(weak))
    }

    func testLaunchVelocityScalesWithBonus() {
        let base = StonePhysics.launchVelocity(power: 0.8, angleRadians: 0.4)
        let boosted = StonePhysics.launchVelocity(power: 0.8, angleRadians: 0.4, powerBonus: 0.2)
        XCTAssertGreaterThan(StonePhysics.speed(boosted), StonePhysics.speed(base))
    }

    func testShallowFastStoneSkips() {
        var velocity = CGVector(dx: 320, dy: -120)
        var position = CGPoint(x: 100, y: GameConstants.waterSurfaceY - 1)
        let didSkip = StonePhysics.attemptSkip(velocity: &velocity, at: &position)
        XCTAssertTrue(didSkip)
        XCTAssertGreaterThan(velocity.dy, 0)
    }

    func testSteepStoneDoesNotSkip() {
        var velocity = CGVector(dx: 80, dy: -320)
        var position = CGPoint(x: 100, y: GameConstants.waterSurfaceY - 1)
        let didSkip = StonePhysics.attemptSkip(velocity: &velocity, at: &position)
        XCTAssertFalse(didSkip)
    }

    func testBounceAddsUpwardVelocity() {
        var velocity = CGVector(dx: 200, dy: -100)
        StonePhysics.applyBounce(velocity: &velocity, holding: false)
        XCTAssertGreaterThan(velocity.dy, 0)
    }

    func testDoubleBounceStrongerThanSingle() {
        var single = CGVector(dx: 200, dy: -100)
        var double = CGVector(dx: 200, dy: -100)
        StonePhysics.applyBounce(velocity: &single, holding: false)
        StonePhysics.applyDoubleBounce(velocity: &double)
        XCTAssertGreaterThan(double.dy, single.dy)
    }

    func testComboMomentumAddsSpeed() {
        var velocity = CGVector(dx: 200, dy: -80)
        StonePhysics.applyComboMomentum(velocity: &velocity, combo: 4, factor: 0.02)
        XCTAssertGreaterThan(velocity.dx, 200)
    }

    func testDeepSkimLowersMinSkipSpeed() {
        var velocity = CGVector(dx: 70, dy: -40)
        var position = CGPoint(x: 100, y: GameConstants.waterSurfaceY - 1)
        let withoutDeepSkim = StonePhysics.attemptSkip(velocity: &velocity, at: &position)

        var velocity2 = CGVector(dx: 70, dy: -40)
        var position2 = CGPoint(x: 100, y: GameConstants.waterSurfaceY - 1)
        let withDeepSkim = StonePhysics.attemptSkip(
            velocity: &velocity2,
            at: &position2,
            minSpeedReduction: 30
        )

        XCTAssertFalse(withoutDeepSkim)
        XCTAssertTrue(withDeepSkim)
    }

    func testPredictedArcReachesWater() {
        let points = StonePhysics.predictedArcPoints(
            start: CGPoint(x: 72, y: GameConstants.waterSurfaceY + 18),
            power: 0.7,
            angleRadians: 0.4,
            powerBonus: 0.1,
            steps: 8
        )
        XCTAssertGreaterThan(points.count, 2)
        XCTAssertLessThanOrEqual(points.last!.y, GameConstants.waterSurfaceY + 20)
    }
}
