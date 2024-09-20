//
//  Item.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

@Model
final class Item {
    var word: String = ""
    var furigana: String = ""
    var meaning: String = ""
    var addedAt: Date = Date.now
    
    init(word: String, furigana: String, meaning: String, addedAt: Date) {
        self.word = word
        self.furigana = furigana
        self.meaning = meaning
        self.addedAt = addedAt
    }
}
