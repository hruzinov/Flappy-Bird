//
// Created by Evhen Gruzinov on 31.01.2023.
//

import SpriteKit

class ScoreCounterNode: SKSpriteNode {
    static func populate(top position: CGPoint, step: ScoreCounterStep) -> SKSpriteNode {
        let scoreCounter = SKSpriteNode(texture: SKTexture(imageNamed: "0"))

        scoreCounter.setScale(2)

        var padding = 25

        switch step {
        case .left:
            padding *= -1
        case .right:
            padding *= 1
        }

        scoreCounter.position = CGPoint(x:position.x + CGFloat(padding), y: position.y - scoreCounter.size.height * 1.5)
        scoreCounter.zPosition = 20

        return scoreCounter
    }

    enum ScoreCounterStep { case left, right}
}
