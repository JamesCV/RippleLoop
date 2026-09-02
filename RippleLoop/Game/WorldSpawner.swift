import SpriteKit

final class WorldSpawner {
    private var nextSpawnX: CGFloat = 480
    private var spawnIndex = 0
    private let container: SKNode

    init(container: SKNode) {
        self.container = container
    }

    func reset() {
        container.removeAllChildren()
        nextSpawnX = 480
        spawnIndex = 0
    }

    func update(stoneX: CGFloat, distanceMeters: Double) {
        despawn(stoneX: stoneX)
        while nextSpawnX < stoneX + GameConstants.spawnAheadDistance {
            spawnSegment(distanceMeters: distanceMeters)
            nextSpawnX += GameConstants.worldSegmentWidth * CGFloat.random(in: 0.85...1.15)
        }
    }

    private func spawnSegment(distanceMeters: Double) {
        spawnIndex += 1
        let difficulty = min(max(distanceMeters / 1500, 0), 1)

        if spawnIndex > 2 && Double.random(in: 0...1) < 0.35 + difficulty * 0.25 {
            let log = LogObstacle()
            log.position.x = nextSpawnX + CGFloat.random(in: -40...80)
            container.addChild(log)
        }

        let pearlCount = Int.random(in: 1...3)
        for index in 0..<pearlCount {
            let lane: PearlLane
            let roll = Double.random(in: 0...1)
            if roll < 0.35 { lane = .low }
            else if roll < 0.7 { lane = .mid }
            else { lane = .high }

            let pearl = PearlNode(lane: lane)
            pearl.position.x = nextSpawnX + CGFloat(index) * 48 + 20
            container.addChild(pearl)
        }
    }

    private func despawn(stoneX: CGFloat) {
        container.children.forEach { node in
            if node.position.x < stoneX - GameConstants.despawnBehindDistance {
                node.removeFromParent()
            }
        }
    }

    func collectPearls(near stonePosition: CGPoint, magnetRadius: CGFloat) -> Int {
        var collected = 0
        for case let pearl as PearlNode in container.children {
            let dx = pearl.position.x - stonePosition.x
            let dy = pearl.position.y - stonePosition.y
            let distance = hypot(dx, dy)
            if distance <= magnetRadius {
                pearl.collect()
                collected += 1
            }
        }
        return collected
    }

    func checkLogCollision(stonePosition: CGPoint, stoneRadius: CGFloat) -> Bool {
        for case let log as LogObstacle in container.children {
            let rect = log.collisionRect
            let stoneRect = CGRect(
                x: stonePosition.x - stoneRadius,
                y: stonePosition.y - stoneRadius * 0.5,
                width: stoneRadius * 2,
                height: stoneRadius
            )
            if rect.intersects(stoneRect) {
                return true
            }
        }
        return false
    }
}
