import SpriteKit

final class AimOverlay: SKNode {
    private let pathNode = SKShapeNode()
    private let angleSliderTrack = SKShapeNode(rectOf: CGSize(width: 6, height: 180), cornerRadius: 3)
    private let angleSliderHandle = SKShapeNode(circleOfRadius: 10)

    var launchAngle: CGFloat = 0.42
    private(set) var swipePower: CGFloat = 0.55
    private var swipePoints: [CGPoint] = []

    override init() {
        super.init()
        zPosition = 150

        pathNode.strokeColor = SKColor.white.withAlphaComponent(0.85)
        pathNode.lineWidth = 3
        pathNode.lineCap = .round
        pathNode.glowWidth = 1
        addChild(pathNode)

        angleSliderTrack.fillColor = SKColor.black.withAlphaComponent(0.2)
        angleSliderTrack.strokeColor = SKColor.white.withAlphaComponent(0.35)
        angleSliderTrack.lineWidth = 1
        angleSliderTrack.position = CGPoint(x: -28, y: -260)
        addChild(angleSliderTrack)

        angleSliderHandle.fillColor = SKColor.hex("#C9A574")
        angleSliderHandle.strokeColor = SKColor.white.withAlphaComponent(0.8)
        angleSliderHandle.lineWidth = 1.5
        updateSliderHandle()
        addChild(angleSliderHandle)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resetSwipe() {
        swipePoints.removeAll()
        pathNode.path = nil
        swipePower = 0.55
    }

    func appendSwipePoint(_ point: CGPoint) {
        swipePoints.append(point)
        guard swipePoints.count >= 2 else { return }

        let path = CGMutablePath()
        path.move(to: swipePoints[0])
        for point in swipePoints.dropFirst() {
            path.addLine(to: point)
        }
        pathNode.path = path

        let dx = swipePoints.last!.x - swipePoints.first!.x
        let dy = swipePoints.last!.y - swipePoints.first!.y
        let distance = hypot(dx, dy)
        swipePower = min(max(distance / 220, 0.15), 1.0)
    }

    func updateAngleSlider(at location: CGPoint, in size: CGSize) {
        let trackMinY = size.height * 0.5 - 350
        let trackMaxY = size.height * 0.5 - 170
        let clampedY = min(max(location.y, trackMinY), trackMaxY)
        angleSliderHandle.position = CGPoint(x: -28, y: clampedY - size.height * 0.5)

        let t = (clampedY - trackMinY) / (trackMaxY - trackMinY)
        launchAngle = 0.18 + (1 - t) * 0.52
    }

    func isAngleSliderTouch(_ location: CGPoint, in size: CGSize) -> Bool {
        location.x > size.width - 56
    }

    private func updateSliderHandle() {
        angleSliderHandle.position = CGPoint(x: -28, y: -250)
    }
}