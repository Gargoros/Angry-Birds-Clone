//
//  SKNode+Extensions.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 7.12.24.
//

import SpriteKit

extension SKNode {
    func aspectScale(to size: CGSize, width: Bool, multiplier: CGFloat) {
        let scale = width ? (size.width * multiplier) / self.frame.size.width : (size.height * multiplier) / self.frame.size.height
        
        self.setScale(scale)
    }
}
