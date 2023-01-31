//
// Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class ScoreSpriteNode: SKSpriteNode {
    static func populate(at position: CGPoint, size: CGSize) -> SKSpriteNode {
        let scoreSprite = SKSpriteNode()
        scoreSprite.name = "scoreSprite"

        scoreSprite.size = size

        scoreSprite.physicsBody = SKPhysicsBody(rectangleOf: scoreSprite.size)
        scoreSprite.physicsBody?.categoryBitMask = ColliderType.ui
        scoreSprite.physicsBody?.contactTestBitMask = ColliderType.bird
        scoreSprite.physicsBody?.isDynamic = false

        scoreSprite.position = CGPoint(x:position.x, y: position.y + size.height / 2)
        scoreSprite.zPosition = 2

        return scoreSprite
    }
}
