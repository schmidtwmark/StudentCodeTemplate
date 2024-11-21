//
//  TurtleConsole.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import SpriteKit

extension SKSpriteNode {
    func runAsync(_ action: SKAction) async {
        await withCheckedContinuation { continuation in
            self.run(action) {
                continuation.resume()
            }
        }
    }
}

extension CGFloat {
    var radians: CGFloat {
        return self * .pi / 180
    }
}

class Turtle: SKSpriteNode {
    private var rotation: CGFloat = 0

    private enum PenState {
        case up
        case down(CGMutablePath, SKShapeNode)
    }
    private var penState: PenState = .up
    
    init() {
        let texture = SKTexture(imageNamed: "tortoise.fill@2x")
        super.init(texture: texture, color: .green, size: CGSize(width: 40.0, height: 40.0))
        self.colorBlendFactor = 1.0
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func forward(_ distance: CGFloat) async {
        let dx = distance * cos(rotation)
        let dy = distance * sin(rotation)
        let moveAction = SKAction.moveBy(x: dx, y: dy, duration: distance / MOVEMENT_SPEED_0)
        await self.runAsync(moveAction)
    }
    
    func backward(_ distance: CGFloat) async {
        await forward(-distance)
    }
    
    // Trace the path of an arc with a certain radius for @param angle degrees
    // This should both move and rotate the turtle so it is always facing tangent to the circle.
    func arc(radius: CGFloat, angle: CGFloat) async {
        print("Running arc, radius: \(radius), angle: \(angle), position: \(self.position), rotation: \(rotation)")
        
        let counterclockwise = angle >= 0
        let directionMultiplier : CGFloat = counterclockwise ? 1.0 : -1.0
        let center = CGPoint(x: -directionMultiplier * sin(rotation) * radius, y: directionMultiplier * cos(rotation) * radius)
        
        print("Center is: \(center)")
        let startOffset: CGFloat = counterclockwise ? 270.0 : 90.0
        let path = CGMutablePath()
        path.addRelativeArc(center: center, radius: radius, startAngle: startOffset.radians + rotation, delta: angle.radians)
        
        let circumference = abs(2 * .pi * radius * angle / 360)
        let duration = circumference / MOVEMENT_SPEED_0
        rotation += directionMultiplier * angle.radians
        let rotateAction = SKAction.rotate(byAngle: angle.radians, duration: duration)
        let followAction = SKAction.follow(path, asOffset: true , orientToPath: false, duration: duration)
        let group = SKAction.group([rotateAction, followAction])
        
        await self.runAsync(group)
    }

   func rotate(_ angle: CGFloat) async {
        rotation += angle.radians
        let rotateAction = SKAction.rotate(byAngle: angle.radians, duration: abs(angle / ROTATION_SPEED_0))
        await self.runAsync(rotateAction)
    }
    
    func setColor(_ color: UIColor)  {
        self.color = color
        if case .down(_, _) = penState {
            // Call penDown again so the next section has the right color
            penDown()
        }
    }
    
    func penDown() {
        let path = CGMutablePath()
        path.move(to: self.position)
        let pathNode = SKShapeNode()
        pathNode.strokeColor = self.color
        pathNode.lineWidth = 3
        scene?.addChild(pathNode)
        penState = .down(path, pathNode)
    }
    
    func update() {
        if case .down(let path, let pathNode) = penState {
            path.addLine(to: self.position)
            pathNode.path = path
        }
    }
    
    func penUp() {
        penState = .up
    }
}

let ROTATION_SPEED_0 = 90.0 // degrees / second
let MOVEMENT_SPEED_0 = 200.0 // points / second

class TurtleScene: SKScene {
    
    var rotationSpeed = ROTATION_SPEED_0
    var movementSpeed = MOVEMENT_SPEED_0
    var cameraNode: SKCameraNode? // Reference for the camera
    
    func setupCamera() {
        let camera = SKCameraNode()
        self.cameraNode = camera
        self.camera = camera
        addChild(camera)
    }
    
    override func didMove(to view: SKView) {
        setupCamera()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            view.addGestureRecognizer(panGesture)
            
        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let cameraNode = self.cameraNode else { return }
        
        let translation = sender.translation(in: self.view)
        let sceneTranslation = CGPoint(x: translation.x, y: -translation.y) // Invert Y because SpriteKit's coordinate system is flipped.
        
        cameraNode.position = CGPoint(
            x: cameraNode.position.x - sceneTranslation.x,
            y: cameraNode.position.y - sceneTranslation.y
        )

        sender.setTranslation(.zero, in: self.view) // Reset translation to avoid compounding
    }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let cameraNode = self.cameraNode else { return }
        
        if sender.state == .changed {
            let zoomFactor = sender.scale
            let newScale = cameraNode.xScale / zoomFactor // In SpriteKit, smaller scale zooms in
            
            // Clamp the scale to prevent over-zooming
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 5.0
            cameraNode.setScale(max(min(newScale, maxScale), minScale))
            
            sender.scale = 1.0 // Reset scale to avoid compounding
        }
    }
    
    func clampCameraPosition() {
        guard let cameraNode = self.cameraNode else { return }
        
        let xRange = SKRange(lowerLimit: 0, upperLimit: self.size.width)
        let yRange = SKRange(lowerLimit: 0, upperLimit: self.size.height)
        
        cameraNode.position.x = max(min(cameraNode.position.x, xRange.upperLimit), xRange.lowerLimit)
        cameraNode.position.y = max(min(cameraNode.position.y, yRange.upperLimit), yRange.lowerLimit)
    }
    
    override func update(_ currentTime: TimeInterval) {
        clampCameraPosition()
       for node in children {
           if let turtle = node as? Turtle {
               turtle.update()
           }
            
        }
    }

}

extension CGSize {
    var midpoint : CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }
}

@MainActor
class TurtleConsole: BaseConsole<TurtleConsole>, Console {
    
    
    func updateBackground(_ colorScheme: ColorScheme) {
        scene.backgroundColor = colorScheme == .light ?
            .secondarySystemBackground : UIColor(_colorLiteralRed: 28/256, green: 28/256, blue: 30/256, alpha: 1)
    }
    
    required init(colorScheme: ColorScheme) {
        self.scene = TurtleScene()
        super.init(mainFunction: turtleMain)
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .resizeFill
        updateBackground(colorScheme)
        
    }

    var scene: TurtleScene
    
    var disableClear: Bool {
        false
    }
    
    func addTurtle() async throws -> Turtle {
        let turtle = Turtle()
        scene.addChild(turtle)
        return turtle
    }
    
    var title: String { "Turtle" }
    
    override func stop() {
        super.stop()
    }
    
    override func clear() {
        super.clear()
        scene.removeAllChildren()
        scene.setupCamera()
    }
    
}
//func arc(radius: CGFloat, angle: CGFloat) async {
//    
//    let path = CGMutablePath()
//    print("Running arc, radius: \(radius), angle: \(angle), position: \(self.position), rotation: \(rotation)")
//    let center = CGPoint(x: self.position.x + sin(rotation) * radius, y: self.position.y - cos(rotation) * radius)
//    print("Center is: \(center)")
//    path.move(to: self.position)
//    
//    path.addRelativeArc(center: center, radius: radius, startAngle: (rotation + 90).radians, delta: -angle.radians)
//    
//    let circumference = 2 * .pi * radius * angle / 360
//    let duration = circumference / MOVEMENT_SPEED_0
//    let followAction = SKAction.follow(path, duration: duration)
//    rotation -= angle.radians
//    let rotateAction = SKAction.rotate(byAngle: -angle.radians, duration: duration)
////        await self.runAsync(SKAction.group([followAction, rotateAction]))
//    await self.runAsync(followAction)
////        await self.runAsync(rotateAction)
//    
//}
