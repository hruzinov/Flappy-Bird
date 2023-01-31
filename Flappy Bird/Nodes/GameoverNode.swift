//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class GameoverNode: SKSpriteNode {
    
    static func populate(at point: CGPoint) -> SKSpriteNode {
        let gameover = SKSpriteNode(imageNamed: "gameover")
        gameover.position = point
        gameover.zPosition = 20
        return gameover
    }
}
