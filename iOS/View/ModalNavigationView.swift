//
//  ModalNavigationView.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

struct ModalNavigationView: View {
    let word: String
    @State var meaning: String
    @Binding var showingModal: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @State private var furigana: String = ""
    
    var body: some View {
        TextEditor(text: $meaning)
            .multilineTextAlignment(.leading)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray))
            .padding()
            .toolbar {
                ToolbarItemGroup {
                    TextField("振り仮名を入力", text: $furigana)
                        .submitLabel(.done)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.leading)
                    Button("", systemImage: "plus") {
                        addItem(word: word, furigana: furigana, meaning: meaning)
                        showingModal = false
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
