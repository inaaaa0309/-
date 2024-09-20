//
//  MainView.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingModal: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    showingModal = true
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .padding(30)
                        .sheet(isPresented: $showingModal) {
                            ModalView(showingModal: $showingModal)
                        }
                }
                if !items.isEmpty {
                    List {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            VStack {
                                NavigationLink {
                                    NavigationView(item: item)
                                } label: {
                                    Text("\(item.word)（\(item.furigana)）")
                                }
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
        }
     }
     
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
