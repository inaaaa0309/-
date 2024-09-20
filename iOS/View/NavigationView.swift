//
//  NavigationView.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

struct NavigationView: View {
    let item: Item
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @State private var meaning: String = ""
    @State private var furigana: String = ""
    
    @State private var isEditing: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            if isEditing {
                TextEditor(text: $meaning)
                    .multilineTextAlignment(.leading)
                    .focused($isFocused)
                    .padding()
            } else {
                Text(item.meaning)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if isEditing {
                    TextField("振り仮名を編集", text: $furigana)
                        .submitLabel(.done)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(item.furigana)
                        .frame(width: 200, alignment: .trailing)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.trailing)
                }
                if isEditing {
                    Button("保存") {
                        item.meaning = meaning
                        item.furigana = furigana
                        isFocused = false
                        isEditing = false
                    }
                } else {
                    Button("編集") {
                        meaning = item.meaning
                        furigana = item.furigana
                        isEditing = true
                        isFocused = true
                    }
                }
            }
        }
    }
    
    private func changeMeaningFurigana(meaning: String, furigana: String, index: Int) {
          items[index].meaning = meaning
          items[index].furigana = furigana
     }
}
