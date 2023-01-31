//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit

class BackgroundNode: SKSpriteNode {
    
    static func populateDay(at point: CGPoint) -> SKSpriteNode {
        let background = SKSpriteNode(imageNamed: "background-day")
        background.position = point
        background.zPosition = 0
        return background
    }
    
    static func populateNight(at point: CGPoint) -> SKSpriteNode {
        let background = SKSpriteNode(imageNamed: "background-night")
        background.position = point
        background.zPosition = 1
        return background
    }
    
}
