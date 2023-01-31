//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var sceneCenterPoint: CGPoint!
    var backgroundDay: SKSpriteNode!
    var backgroundNight: SKSpriteNode!
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
        
        backgroundDay = BackgroundNode.populateDay(at: sceneCenterPoint)
        backgroundNight = BackgroundNode.populateNight(at: sceneCenterPoint)
        backgroundDay.size = self.size
        backgroundNight.size = self.size
        
        base = SKSpriteNode(imageNamed: "base")
        base.name = "environment"
        base.physicsBody = SKPhysicsBody(rectangleOf: base.size)
        base.physicsBody?.categoryBitMask = ColliderType.environment
        base.physicsBody?.contactTestBitMask = ColliderType.bird
        base.physicsBody?.isDynamic = false
        base.size = CGSize(width: self.size.width, height: self.size.width / 3)
        base.position = CGPoint(x: self.size.width/2, y: 40)
        base.zPosition = 2
        
        welcomeMessage = SKSpriteNode(imageNamed: "message")
        welcomeMessage.position = sceneCenterPoint
        welcomeMessage.zPosition = 20
        welcomeMessage.size = CGSize(width: self.size.width / 1.45, height: self.size.width)
        
        gameover = SKSpriteNode(imageNamed: "gameover")
        gameover.position = sceneCenterPoint
        gameover.zPosition = 20
        
        bird = BirdNode.populate(at: sceneCenterPoint)
        let birdWidth = self.size.width / 8
        let birdHeight = birdWidth / 1.41
        bird.size = CGSize(width: birdWidth, height: birdHeight)
        
        resetStartScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            self.addChild(bird)
            self.addChild(base)
            welcomeMessage.removeFromParent()
            gameState = .playing
            runGravity()
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
        
        self.addChild(backgroundDay)
        self.addChild(welcomeMessage)
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
        bird.run(SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 0.2))
        birdState = .falling
    }
    
    fileprivate func hited() {
        self.birdState = .dead
        self.gameState = .death
        
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
