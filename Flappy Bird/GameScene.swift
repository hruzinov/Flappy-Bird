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
        
        background = BackgroundNode.populate(at: sceneCenterPoint, size: size)
        base = BaseNode.populate(size: size)
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
            resetStartScene()
        }
    }
    
    fileprivate func resetStartScene() {
        removeAllChildren()
        removeAllActions()
        
        gameState = .menu
        birdState = .falling
        
        bird = BirdNode.populate(at: sceneCenterPoint, size: size)
        
        addChild(background)
        addChild(welcomeMessage)

        scoreCounter = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .right)
        scoreCounterDozens = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .left)
        addChild(scoreCounter)
        addChild(scoreCounterDozens)
        updateScoreCounter()
    }
    
    fileprivate func startGame() {
        addChild(bird)
        addChild(base)
        welcomeMessage.removeFromParent()
        gameState = .playing
        gameScore = 0
        updateScoreCounter()
        runGravity()
        spawningPipesAction()
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
        var pipesInterval:Double { 2.0 - Double(gameScore) / 50 }
        
        let spawnPipesWait = SKAction.wait(forDuration: TimeInterval(pipesInterval))
        let spawnPipesAction = SKAction.run { [self] in
            if gameState == .playing {
                spawnPipe()
            }
        }
        let spawnPipesWaitSequence = SKAction.sequence([spawnPipesWait, spawnPipesAction])
        let spawnPipesForever = SKAction.repeatForever(spawnPipesWaitSequence)
        run(spawnPipesForever)
    }
    
    fileprivate func spawnPipe() {
        let safeBorder = 250 - gameScore * 4
        let pipesSpeed = 4.0 - Double(gameScore) / 50

        let pipesArray = PipesNode.populate(size: size, on: nil, safeBorder: safeBorder)
        let pipe = pipesArray[0]
        let pipeReversed = pipesArray[1]

        let scoreSprite = ScoreSpriteNode.populate(
                at: CGPoint(x: pipe.position.x, y: pipe.position.y),
                size: CGSize(width: pipe.size.width, height: CGFloat(safeBorder))
        )

        pipe.run(SKAction.move(to: CGPoint(x: -100, y: pipe.position.y), duration: pipesSpeed))
        pipeReversed.run(SKAction.move(to: CGPoint(x: -100, y: pipeReversed.position.y), duration: pipesSpeed))
        scoreSprite.run(SKAction.move(to: CGPoint(x: -100, y: scoreSprite.position.y), duration: pipesSpeed))
        
        addChild(pipe)
        addChild(pipeReversed)
        addChild(scoreSprite)
    }
    
    fileprivate func jumpUp() {
        birdState = .jumping
        bird.run(SKAction.move(by: CGVector(dx: 0, dy: 150), duration: 0.15))
        birdState = .falling
    }

    fileprivate func addScorePoint() {
        if gameState == .playing {
            gameScore += 1
            updateScoreCounter()
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
                }
            ])

            run(cooldownAction)

        }
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "pipe") { (node, _) in
            let pipe = node as! SKSpriteNode
            if pipe.position.x == -100 {
                pipe.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "scoreSprite") { (node, _) in
            let scoreSprite = node as! SKSpriteNode
            if scoreSprite.position.x == -100 {
                scoreSprite.removeFromParent()
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
        else if firstBody.node?.name == "bird" && secondBody.node?.name == "pipe" { hitted() }
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
