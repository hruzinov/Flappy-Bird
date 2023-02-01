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
    var gameOver: SKSpriteNode!

    var scoreCounter: SKSpriteNode!
    var scoreCounterDozens: SKSpriteNode!

    var bird: SKSpriteNode!
    
    var gameState: GameState = .menu
    var birdState: BirdState = .falling
    var gameScore: Int! = 0
    
    override func didMove(to view: SKView) {
        sceneCenterPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        welcomeMessage = WelcomeNode.populate(size: size, at: sceneCenterPoint)
        gameOver = GameOverNode.populate(at: sceneCenterPoint)
        
        resetStartScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            startGame()
        case .playing:
            jumpUp()
        case .death: ()
        case .gameover:
            view?.isPaused = false
            resetStartScene()
        }
    }
    
    fileprivate func resetStartScene() {
        removeAllChildren()
        removeAllActions()
        
        gameState = .menu
        birdState = .falling
        
        bird = BirdNode.populate(at: sceneCenterPoint, size: size)
        background = BackgroundNode.populate(at: CGPoint(x: sceneCenterPoint.x + 1 , y: sceneCenterPoint.y), size: size)
        base = BaseNode.populate(size: size, position: CGPoint(x: size.width/2, y: 40))
        
        addChild(background)
        addChild(welcomeMessage)

        scoreCounter = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .right)
        scoreCounterDozens = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .left)
        addChild(scoreCounter)
        addChild(scoreCounterDozens)
        updateScoreCounter()
    }
    
    fileprivate func startGame() {
        bird.texture = SKTexture(imageNamed: "bluebird-upflap")
        addChild(bird)
        addChild(base)
        base.run(SKAction.move(by: CGVector(dx: -size.width, dy: 0), duration: 4))
        background.run(SKAction.move(by: CGVector(dx: -size.width * 2.5, dy: 0), duration: 30))
        
        welcomeMessage.removeFromParent()
        gameState = .playing
        gameScore = 0
        updateScoreCounter()
        runGravity()
        spawningPipesAction()
        spawningBases()
        spawningBackgrounds()
    }
    
    fileprivate func runGravity() {
        let fallingSpeed = 0.05
        
        let fallDownWait = SKAction.wait(forDuration: fallingSpeed)
        let fallDownAction = SKAction.run { [self] in
            if birdState != .jumping {
                bird.run(SKAction.move(by: CGVector(dx: 0, dy: -15 - gameScore/10), duration: fallingSpeed))
            }
        }
        let fallDownASequence = SKAction.sequence([fallDownWait, fallDownAction])
        let fallDownForever = SKAction.repeatForever(fallDownASequence)
        run(fallDownForever)
    }
    fileprivate func spawningPipesAction() {
        var pipesInterval: Double { 3.0 - Double(gameScore) / 25 }
        
        let spawnPipesWait = SKAction.wait(forDuration: TimeInterval(pipesInterval))
        let spawnPipesAction = SKAction.run { [self] in
            spawnPipe()
        }
        let spawnPipesWaitSequence = SKAction.sequence([spawnPipesWait, spawnPipesAction])
        let spawnPipesForever = SKAction.repeatForever(spawnPipesWaitSequence)
        run(spawnPipesForever)
    }
    
    fileprivate func spawnPipe() {
        let safeBorder = 250 - gameScore * 4
        let pipesSpeed = 10.0 - Double(gameScore) / 25

        let pipesArray = PipesNode.populate(size: size, on: nil, safeBorder: safeBorder)
        let pipe = pipesArray[0]
        let pipeReversed = pipesArray[1]

        let scoreSprite = ScoreSpriteNode.populate(
                at: CGPoint(x: pipe.position.x, y: pipe.position.y),
                size: CGSize(width: pipe.size.width, height: CGFloat(safeBorder))
        )
        
        let movingVector = CGVector(dx: -size.width * 2.5, dy: 0)
        
        pipe.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        pipeReversed.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        scoreSprite.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        
        addChild(pipe)
        addChild(pipeReversed)
        addChild(scoreSprite)
    }
    
    fileprivate func spawningBases() {
        var baseInterval: Double { 3.0 - Double(gameScore) / 25 }
        
        let spawnBaseWait = SKAction.wait(forDuration: TimeInterval(baseInterval))
        let spawnBaseAction = SKAction.run { [self] in
            let baseSpeed = 10.0 - Double(gameScore) / 25
            let base = BaseNode.populate(size: size, position: CGPoint(x: size.width * 1.5, y: 40))
            let movingVector = CGVector(dx: -size.width * 2.5, dy: 0)

            base.run(SKAction.move(by: movingVector, duration: baseSpeed))
            addChild(base)
        }
        let spawnBaseWaitSequence = SKAction.sequence([spawnBaseAction, spawnBaseWait])
        let spawnBaseForever = SKAction.repeatForever(spawnBaseWaitSequence)
        run(spawnBaseForever)
    }
    fileprivate func spawningBackgrounds() {
        var backgroundInterval: Double { 9.0 - Double(gameScore) / 25 }
        
        let spawnbackgroundWait = SKAction.wait(forDuration: TimeInterval(backgroundInterval))
        let spawnbackgroundAction = SKAction.run { [self] in
            let backgroundSpeed = 30.0 - Double(gameScore) / 25
            let background = BackgroundNode.populate(at: CGPoint(x: size.width * 1.5, y: sceneCenterPoint.y), size: size)
            let movingVector = CGVector(dx: -size.width * 2.5, dy: 0)

            background.run(SKAction.move(by: movingVector, duration: backgroundSpeed))
            addChild(background)
        }
        let spawnBackgroundWaitSequence = SKAction.sequence([spawnbackgroundAction, spawnbackgroundWait])
        let spawnBackgroundForever = SKAction.repeatForever(spawnBackgroundWaitSequence)
        run(spawnBackgroundForever)
    }
    
    fileprivate func jumpUp() {
        birdState = .jumping
        bird.run(SKAction.animate(with: BirdTextures.animationTextures, timePerFrame: 0.075))
        bird.run(SKAction.move(by: CGVector(dx: 0, dy: 150), duration: 0.15))
        birdState = .falling
    }

    fileprivate func addScorePoint() {
        if gameState == .playing {
            gameScore += 1
            updateScoreCounter()
        }
        
        let textureArray: [SKTexture]
        if gameScore % 10 == 0 {
            if (gameScore / 10) % 2 == 1 {
                textureArray = BackgroundTextures.animationTextures
            } else {
                textureArray = BackgroundTextures.animationTexturesReversed
            }
            
            for node in self.children {
                if node.name == "background" { node.run(SKAction.animate(with: textureArray, timePerFrame: 0.05)) }
            }
        }
    }

    fileprivate func updateScoreCounter() {
        let scorePoints = gameScore % 10
        let scorePointsDozens = gameScore / 10

        scoreCounter.texture = SKTexture(imageNamed: String(scorePoints))
        scoreCounterDozens.texture = SKTexture(imageNamed: String(scorePointsDozens))
    }
    
    fileprivate func hitted() {
        if gameState == .playing {

            birdState = .dead
            gameState = .death

            addChild(gameOver)

            let cooldownAction = SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.run { [self] in
                    gameState = .gameover
                    view?.isPaused = true
                }
            ])

            run(cooldownAction)

        }
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "environment") { (node, _) in
            let pipe = node as! SKSpriteNode
            if pipe.position.x < -self.size.width / 2 {
                pipe.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "scoreSprite") { (node, _) in
            let scoreSprite = node as! SKSpriteNode
            if scoreSprite.position.x < -self.size.width / 5 {
                scoreSprite.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "background") { (node, _) in
            let backgroundSprite = node as! SKSpriteNode
            if backgroundSprite.position.x < -self.size.width / 2 {
                backgroundSprite.removeFromParent()
            }
        }
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
        
        if firstBody.node?.name == "bird" && secondBody.node?.name == "environment" { hitted() }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "bird" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if firstBody.node?.name == "bird" && secondBody.node?.name == "scoreSprite" { addScorePoint() }
    }
}
