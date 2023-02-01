//
//  Created by Evhen Gruzinov on 30.01.2023.
//

import SpriteKit

class BackgroundNode: SKSpriteNode {
    
    static func populate(at point: CGPoint, size: CGSize, dayState: DayState) -> SKSpriteNode {
                
        let backgroundTexture: SKTexture
        switch dayState {
        case .day:
            backgroundTexture = BackgroundTextures.backgroundAtlas.textureNamed("background-day")
        case .night:
            backgroundTexture = BackgroundTextures.backgroundAtlas.textureNamed("background-night")
        }
        
        let background = SKSpriteNode(texture: backgroundTexture)
        background.name = "background"
        background.position = point
        background.zPosition = 0
        background.size = size
        return background
    }
    
}

enum DayState { case day, night}

struct BackgroundTextures {
    
    static let backgroundAtlas = SKTextureAtlas(named: "background")
    
    static let animationTextures = [
        backgroundAtlas.textureNamed("background-day"),
        backgroundAtlas.textureNamed("background-switch-1"),
        backgroundAtlas.textureNamed("background-switch-2"),
        backgroundAtlas.textureNamed("background-switch-3"),
        backgroundAtlas.textureNamed("background-switch-4"),
        backgroundAtlas.textureNamed("background-switch-5"),
        backgroundAtlas.textureNamed("background-night")
    ]
    static let animationTexturesReversed: [SKTexture] = animationTextures.reversed()
}
