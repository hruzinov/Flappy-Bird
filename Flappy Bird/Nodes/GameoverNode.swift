//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class GameOverNode: SKSpriteNode {
    
    static func populate(at point: CGPoint) -> SKSpriteNode {
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = point
        gameOver.zPosition = 20
        return gameOver
    }
}
