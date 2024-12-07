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
        let color: UIColor?
        switch birdType {
        case .red: color = UIColor.red
        case .blue: color = UIColor.blue
        case .yellow: color = UIColor.yellow
        case .gray: color = UIColor.lightGray
        }
        super.init(texture: nil, color: color!, size: CGSize(width: 40.0, height: 40.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
