//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class BaseNode: SKSpriteNode {
    
    static func populate(size: CGSize) -> SKSpriteNode {
        let base = SKSpriteNode(imageNamed: "base")
        base.name = "environment"
        base.physicsBody = SKPhysicsBody(rectangleOf: base.size)
        base.physicsBody?.categoryBitMask = ColliderType.environment
        base.physicsBody?.contactTestBitMask = ColliderType.bird
        base.physicsBody?.isDynamic = false
        base.size = CGSize(width: size.width, height: size.width / 3)
        base.position = CGPoint(x: size.width/2, y: 40)
        base.zPosition = 2
        
        return base
    }
}
