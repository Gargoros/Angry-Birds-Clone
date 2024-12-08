//
//  LevelData.swift
//  AngryBirdsClone
//
//  Created by MIKHAIL ZHACHKO on 8.12.24.
//

import Foundation

struct LevelData {
    let birds: [String]
    
    init?(level: Int){
        guard let levelDictionary = Levels.levelsDictionary["Level_\(level)"] as? [String: Any] else { return nil }
        guard let birds = levelDictionary["Birds"] as? [String] else { return nil }
        self.birds = birds
    }
}
