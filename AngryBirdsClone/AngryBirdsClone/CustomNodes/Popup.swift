//
//  Popup.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 8.12.24.
//

import SpriteKit

protocol PopupButtonHandlerDelegate {
    func menuTapped()
    func nextTapped()
    func retryTapped()
}

struct PopupButtons {
    static let menu = 0
    static let next = 1
    static let retry = 2
}

class Popup: SKSpriteNode {

    let type: Int
    var popupButtonHandlerDelegate: PopupButtonHandlerDelegate?
    
    init(type: Int, size: CGSize) {
        self.type = type
        super.init(texture: nil, color: UIColor.clear, size: size)
        setupPopup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupPopup(){
        let background = type == 0 ? SKSpriteNode(imageNamed: "popupcleared") : SKSpriteNode(imageNamed: "popupfailed")
        background.aspectScale(to: size, width: false, multiplier: 0.5)
        
        let menuButton = SpriteKitButton(defaultButtonImage: "popmenu", action: popupButtonHandler, index: PopupButtons.menu)
        let nextButton = SpriteKitButton(defaultButtonImage: "popnext", action: popupButtonHandler, index: PopupButtons.next)
        let retryButton = SpriteKitButton(defaultButtonImage: "popretry", action: popupButtonHandler, index: PopupButtons.retry)
        
        nextButton.isUserInteractionEnabled = type == 0 ? true : false
        
        menuButton.aspectScale(to: background.size, width: true, multiplier: 0.2)
        nextButton.aspectScale(to: background.size, width: true, multiplier: 0.2)
        retryButton.aspectScale(to: background.size, width: true, multiplier: 0.2)
        
        let buttonWidthOffset = retryButton.size.width / 2
        let buttonHeightOffset = retryButton.size.height / 2
        let backgroundWidthOffset = background.size.height / 2
        let backgroundHeightOffset = background.size.height / 2
        
        menuButton.position = CGPoint(x: -backgroundWidthOffset + buttonWidthOffset, y: -backgroundHeightOffset - buttonHeightOffset)
        nextButton.position = CGPoint(x: 0, y: -backgroundHeightOffset - buttonHeightOffset)
        retryButton.position = CGPoint(x: backgroundWidthOffset - buttonWidthOffset, y: -backgroundHeightOffset - buttonHeightOffset)
        background.position = CGPoint(x: 0, y: buttonHeightOffset)
        
        addChild(menuButton)
        addChild(nextButton)
        addChild(retryButton)
        addChild(background)
    }
    func popupButtonHandler(index: Int) {
        switch index {
        case PopupButtons.menu: popupButtonHandlerDelegate?.menuTapped()
        case PopupButtons.next: popupButtonHandlerDelegate?.nextTapped()
        case PopupButtons.retry: popupButtonHandlerDelegate?.retryTapped()
        default: break
        }
    }
}
