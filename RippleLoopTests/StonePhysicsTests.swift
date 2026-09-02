import XCTest
@testable import RippleLoop

final class StonePhysicsTests: XCTestCase {
    func testLaunchVelocityScalesWithPower() {
        let weak = StonePhysics.launchVelocity(power: 0.2, angleRadians: 0.4)
        let strong = StonePhysics.launchVelocity(power: 1.0, angleRadians: 0.4)
        XCTAssertGreaterThan(StonePhysics.speed(strong), StonePhysics.speed(weak))
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
}