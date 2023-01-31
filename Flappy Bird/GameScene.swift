//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var sceneCenterPoint: CGPoint!
    var background: SKSpriteNode!
    var base: SKSpriteNode!
    var welcomeMessage: SKSpriteNode!
    var gameover: SKSpriteNode!
    
    var bird: SKSpriteNode!
    
    var gameState: GameState = .menu
    var birdState: BirdState = .falling
    
    override func didMove(to view: SKView) {
        sceneCenterPoint = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
        background = BackgroundNode.populate(at: sceneCenterPoint, size: self.size)
        base = BaseNode.populate(size: self.size)
        welcomeMessage = WelcomeNode.populate(size: self.size, at: sceneCenterPoint)
        gameover = GameoverNode.populate(at: sceneCenterPoint)
        
        bird = BirdNode.populate(at: sceneCenterPoint, size: self.size)
        
        resetStartScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            startGame()
        case .playing:
            jumpUp()
        case .death:
            resetStartScene()
        }
    }
    
    fileprivate func resetStartScene() {
        self.removeAllChildren()
        
        self.gameState = .menu
        self.birdState = .falling
        
        self.bird.position = CGPoint(x: sceneCenterPoint.x, y: sceneCenterPoint.y / 1.2)
        
        self.addChild(background)
        self.addChild(welcomeMessage)
    }
    
    fileprivate func startGame() {
        self.addChild(bird)
        self.addChild(base)
        welcomeMessage.removeFromParent()
        gameState = .playing
        runGravity()
    }
    
    fileprivate func runGravity() {
        let fallingSpeed = 0.05
        
        let fallDownWait = SKAction.wait(forDuration: fallingSpeed)
        let fallDownAction = SKAction.run { [self] in
            if birdState == .falling {
                bird.run(SKAction.move(by: CGVector(dx: 0, dy: -20), duration: fallingSpeed))
            }
        }
        let fallDownASequence = SKAction.sequence([fallDownWait, fallDownAction])
        let fallDownForever = SKAction.repeatForever(fallDownASequence)
        run(fallDownForever)
    }
    
    fileprivate func jumpUp() {
        birdState = .jumping
        bird.run(SKAction.move(by: CGVector(dx: 0, dy: 150), duration: 0.15))
        birdState = .falling
    }
    
    fileprivate func hited() {
        self.birdState = .dead
        self.gameState = .death
        self.removeAllActions()
        
        self.addChild(gameover)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "bird" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "bird" && secondBody.node?.name == "environment" {
            hited()
        }
    }
    
}
