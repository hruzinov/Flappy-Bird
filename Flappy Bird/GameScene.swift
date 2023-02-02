//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Importing nodes
    var sceneCenterPoint: CGPoint!
    var background: SKSpriteNode!
    var base: SKSpriteNode!
    var welcomeMessage: SKSpriteNode!
    var gameOver: SKSpriteNode!

    var scoreCounter: SKSpriteNode!
    var scoreCounterDozens: SKSpriteNode!

    var bird: SKSpriteNode!
    
    // Importing sound
    var gameStartSound: SKAction!
    var jumpSound: SKAction!
    var pointSound: SKAction!
    var deathSound: SKAction!
    
    // Importing game parametrs
    var gameState: GameState = .menu
    var birdState: BirdState = .falling
    var dayState: DayState = .day
    var gameScore: Int! = 0
    var bestScore: Int! = UserDefaults.standard.integer(forKey: "BestScore")
    
    var environmentSpeed: Double { 8 - (Double(gameScore) / 50) }
    var environmentInterval: Double { environmentSpeed / 2}

    // When view showed
    override func didMove(to view: SKView) {
        sceneCenterPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        // Load core nodes
        welcomeMessage = WelcomeNode.populate(size: size, at: sceneCenterPoint)
        gameOver = GameOverNode.populate(at: sceneCenterPoint)
        
        scoreCounter = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .right)
        scoreCounterDozens = ScoreCounterNode.populate(top: CGPoint(x: sceneCenterPoint.x, y: size.height), step: .left)
        
        // Load sounds
        gameStartSound = SKAction.playSoundFileNamed("swoosh.wav", waitForCompletion: false)
        jumpSound = SKAction.playSoundFileNamed("wing.wav", waitForCompletion: false)
        pointSound = SKAction.playSoundFileNamed("point.wav", waitForCompletion: false)
        deathSound = SKAction.playSoundFileNamed("die.wav", waitForCompletion: false)
        
        resetStartScene()
    }
    
    // When user tap screen
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
    
    // Clean-up scene
    fileprivate func resetStartScene() {
        removeAllChildren()
        removeAllActions()
        
        gameState = .menu
        birdState = .falling
        dayState = .day
        
        bird = BirdNode.populate(at: sceneCenterPoint, size: size)
        background = BackgroundNode.populate(at: CGPoint(x: sceneCenterPoint.x + 1 , y: sceneCenterPoint.y), size: size, dayState: dayState) // +1 becouse of bug with moving background
        base = BaseNode.populate(size: size, position: CGPoint(x: size.width/2, y: 40))
        
        addChild(background)
        addChild(welcomeMessage)
        
        updateScoreCounter(score: bestScore)
        addChild(scoreCounter)
        addChild(scoreCounterDozens)
    }
    
    fileprivate func startGame() {
        bird.texture = SKTexture(imageNamed: "bluebird-upflap")
        addChild(bird)
        addChild(base)
        base.run(SKAction.move(by: CGVector(dx: -size.width, dy: 0), duration: environmentSpeed / 2))
        background.run(SKAction.move(by: CGVector(dx: -size.width * 2.5, dy: 0), duration: environmentSpeed * 16))
        
        welcomeMessage.removeFromParent()
        gameState = .playing
        gameScore = 0
        updateScoreCounter(score: gameScore)
        runGravity()
        spawningPipesAction()
        spawningBases()
        spawningBackgrounds()
        run(gameStartSound)
    }
    
    // Seting up gravity
    fileprivate func runGravity() {
        let fallingSpeed = 45 / size.height
        
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
        let pipesInterval = environmentInterval / 1.5
        let spawnPipesWait = SKAction.wait(forDuration: TimeInterval(pipesInterval))
        
        let spawnPipesAction = SKAction.run { [self] in spawnPipe() }

        
        let spawnPipesWaitSequence = SKAction.sequence([
            spawnPipesAction,
            spawnPipesWait,
            SKAction.run { self.spawningPipesAction() }
        ])
        run(spawnPipesWaitSequence)
    }
    
    fileprivate func spawnPipe() {
        let safeBorder = size.height / 4 - (CGFloat(gameScore) * size.height / 400)
        let pipesSpeed = environmentSpeed

        let pipesArray = PipesNode.populate(size: size, on: nil, safeBorder: Int(safeBorder))
        let pipe = pipesArray[0]
        let pipeReversed = pipesArray[1]

        let scoreSprite = ScoreSpriteNode.populate(
                at: CGPoint(x: pipe.position.x, y: pipe.position.y),
                size: CGSize(width: pipe.size.width, height: CGFloat(safeBorder))
        )
        
        let movingVector = CGVector(dx: -size.width * 2, dy: 0)
        
        pipe.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        pipeReversed.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        scoreSprite.run(SKAction.move(by: movingVector, duration: pipesSpeed))
        
        addChild(pipe)
        addChild(pipeReversed)
        addChild(scoreSprite)
    }
    
    fileprivate func spawningBases() {
        let spawnBaseWait = SKAction.wait(forDuration: TimeInterval(environmentInterval))
        let spawnBaseAction = SKAction.run { [self] in
            let base = BaseNode.populate(size: size, position: CGPoint(x: size.width * 1.5, y: 40))
            let movingVector = CGVector(dx: -size.width * 2, dy: 0)

            base.run(SKAction.move(by: movingVector, duration: environmentSpeed))
            addChild(base)
        }
        let spawnBaseWaitSequence = SKAction.sequence([
            spawnBaseAction,
            spawnBaseWait,
            SKAction.run { self.spawningBases() }
        ])
        run(spawnBaseWaitSequence)
    }
    
    fileprivate func spawningBackgrounds() {
        let backgroundInterval = environmentInterval * 7.5
        let spawnbackgroundWait = SKAction.wait(forDuration: TimeInterval(backgroundInterval))
        let spawnbackgroundAction = SKAction.run { [self] in
            let backgroundSpeed = environmentSpeed * 15
            let background = BackgroundNode.populate(at: CGPoint(x: size.width * 1.5, y: sceneCenterPoint.y), size: size, dayState: dayState)
            let movingVector = CGVector(dx: -size.width * 2.5, dy: 0)

            background.run(SKAction.move(by: movingVector, duration: backgroundSpeed))
            addChild(background)
        }
        let spawnBackgroundWaitSequence = SKAction.sequence([
            spawnbackgroundAction,
            spawnbackgroundWait,
            SKAction.run { self.spawningBackgrounds() }
        ])
        run(spawnBackgroundWaitSequence)
    }
    
    fileprivate func jumpUp() {
        birdState = .jumping
        run(jumpSound)
        bird.run(SKAction.animate(with: BirdTextures.animationTextures, timePerFrame: 0.075))
        bird.run(SKAction.move(by: CGVector(dx: 0, dy: size.height / 7), duration: 0.15))
        birdState = .falling
    }

    fileprivate func addScorePoint() {
        if gameState == .playing {
            gameScore += 1
            updateScoreCounter(score: gameScore)
            run(pointSound)
            
            if gameScore % 10 == 0 {
                let textureArray: [SKTexture]
                if (gameScore / 10) % 2 == 1 {
                    textureArray = BackgroundTextures.animationTextures
                    dayState = .night
                } else {
                    textureArray = BackgroundTextures.animationTexturesReversed
                    dayState = .day
                }
                
                for node in self.children {
                    if node.name == "background" { node.run(SKAction.animate(with: textureArray, timePerFrame: 0.05)) }
                }
            }
        }
    }

    fileprivate func updateScoreCounter(score: Int) {
        let scorePoints = score % 10
        let scorePointsDozens = score / 10

        scoreCounter.texture = SKTexture(imageNamed: String(scorePoints))
        scoreCounterDozens.texture = SKTexture(imageNamed: String(scorePointsDozens))
    }
    
    fileprivate func hitted() {
        if gameState == .playing {
            run(deathSound)
            birdState = .dead
            gameState = .death
            addChild(gameOver)
            if gameScore > bestScore {
                UserDefaults.standard.setValue(gameScore, forKey: "BestScore")
                bestScore = gameScore
            }
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
            if pipe.position.x <= -self.size.width / 2 {
                pipe.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "base") { (node, _) in
            let env = node as! SKSpriteNode
            // +3 for compensate bug with node
            if env.position.x <= -self.size.width / 2 + 3 {
                env.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "scoreSprite") { (node, _) in
            let scoreSprite = node as! SKSpriteNode
            if scoreSprite.position.x <= -self.size.width / 5 {
                scoreSprite.removeFromParent()
            }
        }
        enumerateChildNodes(withName: "background") { (node, _) in
            let backgroundSprite = node as! SKSpriteNode
            if backgroundSprite.position.x <= -self.size.width / 2 {
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
        
        if firstBody.node?.name == "bird" && secondBody.node?.name == "pipe" { hitted() }
        if firstBody.node?.name == "bird" && secondBody.node?.name == "base" { hitted() }
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
