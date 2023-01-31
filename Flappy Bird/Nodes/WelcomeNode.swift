//
//  Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class WelcomeNode: SKSpriteNode {
    
    static func populate(size: CGSize, at point: CGPoint) -> SKSpriteNode {
        let welcomeMessage = SKSpriteNode(imageNamed: "message")
        welcomeMessage.position = point
        welcomeMessage.zPosition = 20
        welcomeMessage.size = CGSize(width: size.width / 1.45, height: size.width)
        
        return welcomeMessage
    }
}
