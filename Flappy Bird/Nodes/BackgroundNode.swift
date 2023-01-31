//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit

class BackgroundNode: SKSpriteNode {
    
    static func populate(at point: CGPoint, size: CGSize) -> SKSpriteNode {
        let backgroundTexture = SKTexture(imageNamed: "background-day")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.position = point
        background.zPosition = 0
        background.size = size
        return background
    }
    
}
