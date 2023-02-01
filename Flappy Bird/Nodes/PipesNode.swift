//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class PipesNode: SKSpriteNode {
    
    static func populate(size: CGSize, on position: CGPoint?, safeBorder: Int) -> [SKSpriteNode] {
        let pipe = SKSpriteNode(imageNamed: "pipe-green")
        pipe.name = "pipe"
        pipe.size = CGSize(width: size.width / 5, height: size.height)
        pipe.anchorPoint = CGPoint(x: 0.5, y: 1)
        pipe.physicsBody = SKPhysicsBody(edgeLoopFrom: pipe.frame)
        pipe.physicsBody?.isDynamic = false
        let pipeReversed = SKSpriteNode(imageNamed: "pipe-green")
        
        pipeReversed.anchorPoint = CGPoint(x: 0.5, y: 0)
        pipeReversed.name = "pipe"
        pipeReversed.size = CGSize(width: size.width / 5, height: size.height)
        pipeReversed.physicsBody = SKPhysicsBody(edgeLoopFrom: pipeReversed.frame)
        pipeReversed.physicsBody?.isDynamic = false
        
        if let position = position {
            pipe.position = position
            
        } else {
            pipe.position = randomPosition(safeBorder: safeBorder)
        }
        pipeReversed.position = CGPoint(x: pipe.position.x, y: pipe.position.y + CGFloat(safeBorder))
        pipe.zPosition = 2
        pipeReversed.zPosition = 2
        
        return [pipe, pipeReversed]
    }
    
    fileprivate static func randomPosition(safeBorder: Int) -> CGPoint {
        let screen = UIScreen.main.bounds
        
        let x = Int(screen.width + 50)
        let y = Int.random(in: 50+safeBorder...Int(screen.height) - safeBorder)
        
        let point = CGPoint(x: x, y: y)
        
        return point
    }
}
