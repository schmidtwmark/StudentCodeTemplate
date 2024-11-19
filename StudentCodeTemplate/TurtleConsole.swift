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

    func rotate(_ angle: CGFloat) async {
        rotation += angle * .pi / 180
        let rotateAction = SKAction.rotate(byAngle: angle * .pi / 180, duration: abs(angle / ROTATION_SPEED_0))
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

    override func didMove(to view: SKView) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        print("Calling update")
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
        super.init(mainFunction: turtleMain)
        self.scene = TurtleScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .resizeFill
        updateBackground(colorScheme)
        
    }

    var scene: SKScene = SKScene()
    
    var disableClear: Bool {
        false
    }
    
    func addTurtle() async throws -> Turtle {
        let turtle = Turtle()
        turtle.position = scene.size.midpoint
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
    }
    
}
