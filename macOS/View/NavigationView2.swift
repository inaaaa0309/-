//
//  NavigationView2.swift
//  macOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

struct NavigationView2: View {
    @Binding var word: String
    @State var meaning: String
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var furigana: String = ""
    
    var body: some View {
        TextEditor(text: $meaning)
            .font(.system(size: 15))
            .toolbar {
                ToolbarItemGroup {
                    TextField("振り仮名を入力", text: $furigana)
                        .font(.system(size: 20))
                        .frame(minWidth: 150)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing)
                    Button {
                        addItem(word: word, furigana: furigana, meaning: meaning)
                        word = ""
                        dismiss()
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    }
                    .disabled(furigana.isEmpty || existsInItems(word: word, furigana: furigana))
                }
            }
    }
    
    private func addItem(word: String, furigana: String, meaning: String) {
        withAnimation {
            let newItem = Item(word: word, furigana: furigana, meaning: meaning, addedAt: Date.now)
            modelContext.insert(newItem)
        }
    }
    
    private func existsInItems(word: String, furigana: String) -> Bool {
        for item in items {
            if item.word == word, item.furigana == furigana {
                return true
            }
        }
        return false
    }
}
