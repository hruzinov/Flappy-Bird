//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class BaseNode: SKSpriteNode {
    
    static func populate(size: CGSize, position: CGPoint) -> SKSpriteNode {
        let base = SKSpriteNode(imageNamed: "base")
        base.name = "base"
        base.size = CGSize(width: size.width, height: size.width / 3)
        base.position = position
        base.zPosition = 3
        base.xScale = 1.1
        
        base.physicsBody = SKPhysicsBody(rectangleOf: base.size)
        base.physicsBody?.categoryBitMask = ColliderType.environment
        base.physicsBody?.contactTestBitMask = ColliderType.bird
        base.physicsBody?.isDynamic = false
        
        return base
    }
}
