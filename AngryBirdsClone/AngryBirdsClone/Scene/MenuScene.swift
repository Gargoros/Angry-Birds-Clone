//
//  MenuScene.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 7.12.24.
//

import SpriteKit

class MenuScene: SKScene {
    
    var sceneManagerDelegate: SceneManagerDelegate?
    
    override func didMove(to view: SKView) {
        setupMenu()
    }
}

extension MenuScene {
    private func setupMenu(){
        let background = SKSpriteNode(imageNamed: "menuBackground")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.aspectScale(to: frame.size, width: true, multiplier: 1)
        background.zPosition = ZPosition.background
        addChild(background)
        
        let button = SpriteKitButton(defaultButtonImage: "playButton", action: goToLevelScene, index: 0)
        button.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 0.8)
        button.aspectScale(to: frame.size, width: false, multiplier: 0.2)
        button.zPosition = ZPosition.hubLabel
        addChild(button)
    }
    private func goToLevelScene(_: Int){
        sceneManagerDelegate?.presentLevelScene()
    }
}
