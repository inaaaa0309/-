//
//  NavigationView1.swift
//  macOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

struct NavigationView1: View {
    let item: Item
    let index: Int
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var meaning: String = ""
    @State private var furigana: String = ""
    
    @State private var isEditing: Bool = false
    @FocusState private var isFocused: Bool
    
    @State private var showingAlert: Bool = false
    
    var body: some View {
        ZStack {
            if isEditing {
                TextEditor(text: $meaning)
                    .font(.system(size: 15))
                    .focused($isFocused)
            } else {
                Text(item.meaning)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(item.word)
                        .font(.system(size: 20))
                        .bold()
                }
                ToolbarItemGroup {
                    Spacer()
                    ZStack {
                        if isEditing {
                            TextField("振り仮名を編集", text: $furigana)
                                .font(.system(size: 20))
                                .frame(minWidth: 150)
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text(item.furigana)
                                .font(.system(size: 20))
                                .frame(alignment: .trailing)
                        }
                    }
                    .padding(.trailing, 15)
                    if isEditing {
                        Button {
                            item.meaning = meaning
                            item.furigana = furigana
                            isFocused = false
                            isEditing = false
                        } label: {
                            Text("保存")
                                .font(.system(size: 15))
                                .padding(.horizontal, 5)
                        }
                    } else {
                        Button {
                            meaning = item.meaning
                            furigana = item.furigana
                            isEditing = true
                            isFocused = true
                        } label: {
                            Text("編集")
                                .font(.system(size: 15))
                                .padding(.horizontal, 5)
                        }
                    }
                    Button {
                        showingAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    }
                    .alert("本当に削除しますか？", isPresented: $showingAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            dismiss()
                            deleteItem(index: index)
                        }
                    }
                }
            }
    }
    
    private func deleteItem(index: Int) {
        withAnimation {
            modelContext.delete(items[index])
        }
    }
}
