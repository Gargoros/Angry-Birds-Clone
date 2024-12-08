//
//  LevelScene.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 7.12.24.
//

import SpriteKit

class LevelScene: SKScene {
    
    var sceneManagerDelegate: SceneManagerDelegate?

    override func didMove(to view: SKView) {
        setupLevelSelection()
    }
}

extension LevelScene {
    private func setupLevelSelection(){
        let background = SKSpriteNode(imageNamed: "levelBackground")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.aspectScale(to: frame.size, width: true, multiplier: 1)
        background.zPosition = ZPosition.background
        addChild(background)
        
        var level = 1
        let columnStartingPoint = self.frame.midX / 2
        let rowStartingPoint = self.frame.midY + self.frame.midY / 2
        
        for row in 0..<3 {
            for column in 0..<3 {
                let levelBoxButton = SpriteKitButton(defaultButtonImage: "woodButton", action: goToGameSceneFor, index: level)
                levelBoxButton.position = CGPoint(
                    x: columnStartingPoint + CGFloat(column) * columnStartingPoint,
                    y: rowStartingPoint - CGFloat(row) * self.frame.midY / 2
                )
                levelBoxButton.zPosition = ZPosition.hubBackground
                addChild(levelBoxButton)
                let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                levelLabel.fontSize = 200.0
                levelLabel.verticalAlignmentMode = .center
                levelLabel.text = "\(level)"
                levelLabel.aspectScale(to: levelBoxButton.size, width: false, multiplier: 0.5)
                levelLabel.zPosition = ZPosition.hubLabel
                levelBoxButton.addChild(levelLabel)
                levelBoxButton.aspectScale(to: self.frame.size, width: false, multiplier: 0.2)
                
                level += 1
            }
        }
    }
    private func goToGameSceneFor(level: Int){
        sceneManagerDelegate?.presentGameSceneFor(level: level)
    }
}
