import SpriteKit

final class AimOverlay: SKNode {
    private let pathNode = SKShapeNode()
    private let arcPreviewNode = SKShapeNode()
    private let angleSliderTrack = SKShapeNode(rectOf: CGSize(width: 6, height: 180), cornerRadius: 3)
    private let angleSliderHandle = SKShapeNode(circleOfRadius: 10)

    var launchAngle: CGFloat = 0.42
    private(set) var swipePower: CGFloat = 0.55
    private var swipePoints: [CGPoint] = []
    private var arcPreviewSteps = 4
    private var launchPowerBonus: CGFloat = 0

    override init() {
        super.init()
        zPosition = 150

        arcPreviewNode.strokeColor = SKColor.white.withAlphaComponent(0.35)
        arcPreviewNode.lineWidth = 2
        arcPreviewNode.lineCap = .round
        arcPreviewNode.lineJoin = .round
        addChild(arcPreviewNode)

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

    func configureArcPreview(steps: Int, launchPowerBonus: CGFloat) {
        arcPreviewSteps = max(steps, 1)
        self.launchPowerBonus = launchPowerBonus
        refreshArcPreview()
    }

    func resetSwipe() {
        swipePoints.removeAll()
        pathNode.path = nil
        swipePower = 0.55
        refreshArcPreview()
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
        refreshArcPreview()
    }

    func updateAngleSlider(at location: CGPoint, in size: CGSize) {
        let trackMinY = size.height * 0.5 - 350
        let trackMaxY = size.height * 0.5 - 170
        let clampedY = min(max(location.y, trackMinY), trackMaxY)
        angleSliderHandle.position = CGPoint(x: -28, y: clampedY - size.height * 0.5)

        let t = (clampedY - trackMinY) / (trackMaxY - trackMinY)
        launchAngle = 0.18 + (1 - t) * 0.52
        refreshArcPreview()
    }

    func isAngleSliderTouch(_ location: CGPoint, in size: CGSize) -> Bool {
        location.x > size.width - 56
    }

    private func refreshArcPreview() {
        guard arcPreviewSteps > 0 else {
            arcPreviewNode.path = nil
            return
        }

        let start = CGPoint(x: -size.width * 0.72, y: -size.height * 0.5 + GameConstants.waterSurfaceY + 18)
        let points = StonePhysics.predictedArcPoints(
            start: start,
            power: swipePower,
            angleRadians: launchAngle,
            powerBonus: launchPowerBonus,
            steps: arcPreviewSteps
        )

        guard points.count >= 2 else {
            arcPreviewNode.path = nil
            return
        }

        let path = CGMutablePath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        arcPreviewNode.path = path
    }

    private var size: CGSize {
        parent?.scene?.size ?? CGSize(width: GameConstants.sceneWidth, height: GameConstants.sceneHeight)
    }

    private func updateSliderHandle() {
        angleSliderHandle.position = CGPoint(x: -28, y: -250)
    }
}
