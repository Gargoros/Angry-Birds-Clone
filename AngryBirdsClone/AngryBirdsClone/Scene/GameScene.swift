//
//  GameScene.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 7.12.24.
//

import SpriteKit
import GameplayKit

enum RoundState {
    case ready, flying, finished, animating, gameOver
}

class GameScene: SKScene {
    //MARK: - Properties
    
    var sceneManagerDelegate: SceneManagerDelegate?
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    
    var maxScale: CGFloat = 0.0
    
    var bird = Bird(birdType: .red)
    var birds: [Bird] = [Bird]()
    let anchor = SKNode()
    var enemies = 0 {
        didSet{
            if enemies < 1 {
                roundState = .gameOver
                presentPopup(victory: true)
            }
        }
    }
    var level: Int?
    var roundState = RoundState.ready
    
    //MARK: - Views
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        guard let level = level else { return }
        guard let levelData = LevelData(level: level) else { return }
        for birdColor in levelData.birds {
            if let newBirdType = BirdType(rawValue: birdColor) {
                birds.append(Bird(birdType: newBirdType))
            }
        }
        
        setupLevel()
        setupGestureRecognizers()
    }
    
    override func didSimulatePhysics() {
        guard let physicsBody = bird.physicsBody else { return }
        if roundState == .flying && physicsBody.isResting {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            bird.removeFromParent()
            roundState = .finished
        }
    }
    
    
}
//MARK: - CONFIG
extension GameScene {
    //MARK: - SETUP
    private func setupLevel(){
        if let mapNode = childNode(withName: "Tile Map Node") as? SKTileMapNode {
            self.mapNode = mapNode
            maxScale = mapNode.mapSize.width / frame.size.width
        }
        
        addCamera()
        
        //MARK: - BLOCKS
        for child in mapNode.children {
            if let child = child as? SKSpriteNode {
                guard let name = child.name else { continue }
                switch name {
                case "wood","stone","glass":
                    if let block = createBlock(from: child, name: name) {
                        mapNode.addChild(block)
                        child.removeFromParent()
                    }
                case "orange": 
                    if let enemy = createEnemy(from: child, name: name) {
                        mapNode.addChild(enemy)
                        enemies += 1
                        child.removeFromParent()
                    }
                default: break
                }
            }
        }
        
        //MARK: - SCENE PHYSICS
        let physicsRect = CGRect(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsRect)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        physicsBody?.contactTestBitMask = PhysicsCategory.bird | PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.all
        
        anchor.position = CGPoint(x: mapNode.frame.midX / 2, y: mapNode.frame.midY / 2)
        addChild(anchor)
        
        addSlingshot()
        addBird()
    }
    //MARK: - CAMERA
    private func addCamera(){
        guard let view = view else { return }
        gameCamera.position = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
        addChild(gameCamera)
    }
    //MARK: - GESTURE SETUP
    private func setupGestureRecognizers(){
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        view.addGestureRecognizer(panRecognizer)
        view.addGestureRecognizer(pinchRecognizer)
    }
    //MARK: - SLINGSHOT
    private func addSlingshot(){
        let slingshot = SKSpriteNode(imageNamed: "slingshot")
        let scaleSize = CGSize(width: 0, height: mapNode.frame.midY / 2 - mapNode.tileSize.height / 2)
        slingshot.aspectScale(to: scaleSize, width: false, multiplier: 1.0)
        slingshot.position = CGPoint(x: anchor.position.x, y: mapNode.tileSize.height + slingshot.size.height / 2)
        slingshot.zPosition = ZPosition.obstacles
        mapNode.addChild(slingshot)
    }
    //MARK: - BIRD
    private func addBird(){
        if birds.isEmpty {
            roundState = .gameOver
            presentPopup(victory: false)
            return
        }
        bird = birds.removeFirst()
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.all
        bird.physicsBody?.collisionBitMask = PhysicsCategory.block | PhysicsCategory.edge
        bird.physicsBody?.isDynamic = false
        bird.position = anchor.position
        bird.zPosition = ZPosition.bird
        addChild(bird)
        bird.aspectScale(to: mapNode.tileSize, width: true, multiplier: 1.0)
        constraintToAnchor(active: true)
        roundState = .ready
    }
    private func constraintToAnchor(active: Bool) {
        if active {
            let slingRange = SKRange(lowerLimit: 0.0, upperLimit: bird.size.width * 3)
            let positionConstraint = SKConstraint.distance(slingRange, to: anchor)
            bird.constraints = [positionConstraint]
        } else {
            bird.constraints?.removeAll()
        }
    }
    //MARK: - BLOCK
    private func createBlock(from placeholder: SKSpriteNode, name: String) -> Block? {
        guard let type = BlockType(rawValue: name) else { return nil }
        let block = Block(type: type)
        block.size = placeholder.size
        block.position = placeholder.position
        block.zRotation = placeholder.zRotation
        block.zPosition = ZPosition.obstacles
        block.createPhysicsBody()
        return block
    }
    //MARK: - ENEMY
    private func createEnemy(from placeholder: SKSpriteNode, name: String) -> Enemy? {
        guard let type = EnemyType(rawValue: name) else { return nil }
        let enemy = Enemy(type: type)
        enemy.size = placeholder.size
        enemy.position = placeholder.position
        enemy.zRotation = placeholder.zRotation
        enemy.zPosition = ZPosition.obstacles
        enemy.createPhysicsBody()
        return enemy
    }
    //MARK: - POPUPS
    //MARK: - refactor that part
    private func presentPopup(victory: Bool) {
        if victory {
            let popup = Popup(type: 0, size: frame.size)
            popup.zPosition = ZPosition.hubBackground
            popup.popupButtonHandlerDelegate = self
            gameCamera.addChild(popup)
        } else {
            let popup = Popup(type: 1, size: frame.size)
            popup.zPosition = ZPosition.hubBackground
            popup.popupButtonHandlerDelegate = self
            gameCamera.addChild(popup)
        }
    }
}
//MARK: - GESTURES
extension GameScene {
    //MARK: - PAN
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view) * gameCamera.yScale
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    //MARK: - PINCH
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        guard let view = view else { return }
        if sender.numberOfTouches == 2 {
            let locationInView = sender.location(in: view)
            let location = convertPoint(fromView: locationInView)
            if sender.state == .changed {
                let convertedScale = 1 / sender.scale
                let newScale = gameCamera.yScale * convertedScale
                if newScale < maxScale && newScale > 0.5 {
                    gameCamera.setScale(newScale)
                }
                let locationAfterScale = convertPoint(fromView: locationInView)
                let locationDelta = location - locationAfterScale
                let newPosition = gameCamera.position + locationDelta
                gameCamera.position = newPosition
                sender.scale = 1.0
                gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            }
        }
    }
}
//MARK: - TOUCHES
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch roundState {
        case .ready:
            if let touch = touches.first {
                let location = touch.location(in: self)
                if bird.contains(location) {
                    panRecognizer.isEnabled = false
                    bird.grabbed = true
                    bird.position = location
                }
            }
        case .flying: break
        case .finished:
            guard let view = view else { return }
            roundState = .animating
            let moveCameraBackAction = SKAction.move(to: CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2), duration: 2.0)
            moveCameraBackAction.timingMode = .easeInEaseOut
            gameCamera.run(moveCameraBackAction, completion: {
                self.panRecognizer.isEnabled = true
                self.addBird()
            })
        case .animating: break
        case .gameOver: break
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if bird.grabbed {
                let location = touch.location(in: self)
                bird.position = location
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bird.grabbed {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: bird)
            bird.grabbed = false
            bird.flying = true
            roundState = .flying
            constraintToAnchor(active: false)
            let dx = anchor.position.x - bird.position.x
            let dy = anchor.position.y - bird.position.y
            let impulse = CGVector(dx: dx * 1.4, dy: dy * 1.4)
            bird.physicsBody?.applyImpulse(impulse)
            bird.isUserInteractionEnabled = false
        }
    }
}
//MARK: - CONTACT
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case PhysicsCategory.bird | PhysicsCategory.block, PhysicsCategory.block | PhysicsCategory.edge:
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            } else if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let bird = contact.bodyA.node as? Bird {
                bird.flying = false
            } else if let bird = contact.bodyB.node as? Bird {
                bird.flying = false
            }
        case PhysicsCategory.block | PhysicsCategory.block:
            if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        case PhysicsCategory.bird | PhysicsCategory.edge:
            bird.flying = false
        case PhysicsCategory.bird | PhysicsCategory.enemy:
            if let enemy = contact.bodyA.node as? Enemy {
                if enemy.impact(with: Int(contact.collisionImpulse)){
                    enemies -= 1
                }
            }
            if let enemy = contact.bodyB.node as? Enemy {
                if enemy.impact(with: Int(contact.collisionImpulse)){
                    enemies -= 1
                }
            }
        default:
            break
        }
    }
}

extension GameScene: PopupButtonHandlerDelegate {
    func menuTapped() {
        sceneManagerDelegate?.presentLevelScene()
    }
    func nextTapped() {
        if let level = level {
            sceneManagerDelegate?.presentGameSceneFor(level: level + 1)
        }
    }
    func retryTapped() {
        if let level = level {
            sceneManagerDelegate?.presentGameSceneFor(level: level)
        }
    }
}
