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
        case down
    }
    
    init() {
        // Create a texture using SF Symbol
        let turtleImage = UIImage(systemName: "tortoise.fill")!.withTintColor(.red, renderingMode: .alwaysTemplate)
        let texture = SKTexture(image: turtleImage)
        super.init(texture: texture, color: .red, size: CGSize(width: 40.0, height: 40.0))
    
        self.color = .red
        self.colorBlendFactor = 0.5
        self.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        self.position = CGPoint(x: 100, y: 100)

    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func forward(_ distance: CGFloat) async {
        let dx = distance * cos(rotation)
        let dy = distance * sin(rotation)
        let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
        await self.runAsync(moveAction)
    }

    func rotate(_ angle: CGFloat) async {
        rotation += angle * .pi / 180
        let rotateAction = SKAction.rotate(byAngle: angle * .pi / 180, duration: 0.5)
        await self.runAsync(rotateAction)
    }
}

class TurtleScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .white
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
        self.scene = SKScene()
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
