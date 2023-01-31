//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit

struct ColliderType {
    static let bird: UInt32 = 1
    static let environment: UInt32 = 2
}

class BirdNode: SKSpriteNode {
    
    static var state: BirdState = .falling
    
    static func populate(at point: CGPoint) -> SKSpriteNode {
        
        let birdTexture = SKTexture(imageNamed: "bluebird-midflap")
        let bird = SKSpriteNode(texture: birdTexture)
        
        bird.name = "bird"
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.categoryBitMask = ColliderType.bird
        bird.physicsBody?.collisionBitMask = ColliderType.environment
        bird.physicsBody?.contactTestBitMask = ColliderType.environment
        
        bird.position = CGPoint(x: point.x, y: point.y / 1.2)
        
        bird.zPosition = 10
        
        return bird
        
    }
    
}
