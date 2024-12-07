//
//  Bird.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 7.12.24.
//

import SpriteKit

enum BirdType: String {
    case red, blue, yellow, gray
}

class Bird: SKSpriteNode {
    
    var birdType: BirdType
    var grabbed: Bool = false
    var flying: Bool = false {
        didSet {
            if flying {
                physicsBody?.isDynamic = true
            }
        }
    }
    
    init(birdType: BirdType) {
        self.birdType = birdType
        let texture  = SKTexture(imageNamed: birdType.rawValue + "1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
