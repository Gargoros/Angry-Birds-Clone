//
//  Enemy.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 8.12.24.
//

import SpriteKit

enum EnemyType: String {
    case orange
}

class Enemy: SKSpriteNode {

    let type: EnemyType
    var health: Int
    let animationFrames: [SKTexture]
    
    init(type: EnemyType) {
        self.type = type
        animationFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: type.rawValue), withName: type.rawValue)
        switch type { case .orange: health = 100 }
        let texture = SKTexture(imageNamed: type.rawValue + "1")
        super.init(texture: texture, color: UIColor.clear, size: CGSize.zero)
        animateEnemy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func animateEnemy() {
        run(SKAction.repeatForever(SKAction.animate(with: animationFrames, timePerFrame: 0.3, resize: false, restore: true)))
    }
    func createPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.all
        physicsBody?.collisionBitMask = PhysicsCategory.all
    }
    func impact(with force: Int) -> Bool {
        health -= force
        if health < 1 {
            removeFromParent()
            return true
        }
        return false
    }
}
