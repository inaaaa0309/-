//
//  MainView.swift
//  macOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import Alamofire
import Kanna
import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @State private var word: String = ""
    
    @State private var meanings: [String] = []
    
    @State private var searched: Bool = false
    @State private var notExist: Bool = false
    
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 15) {
                    HStack {
                        TextField("語彙の意味を検索", text: $word)
                            .font(.system(size: 30))
                            .textFieldStyle(.plain)
                            .onChange(of: word) {
                                searched = false
                                notExist = false
                            }
                            .onSubmit {
                                if !word.isEmpty || searched {
                                    DispatchQueue.global().async {
                                        meanings = search(word: word)
                                        if meanings.isEmpty {
                                            notExist = true
                                        } else {
                                            searched = true
                                        }
                                    }
                                }
                            }
                        Spacer()
                        if !word.isEmpty {
                            Button {
                                word = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.gray, lineWidth: 3)
                    }
                    Button {
                        DispatchQueue.global().async {
                            meanings = search(word: word)
                            if meanings.isEmpty {
                                notExist = true
                            } else {
                                searched = true
                            }
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(word.isEmpty || searched)
                }
                .padding(.horizontal, 50)
                .padding(.top, items.isEmpty ? 0 : 10)
                if notExist {
                    Text("その語彙の意味はヒットしませんでした")
                        .font(.system(size: 15))
                        .bold()
                        .foregroundStyle(.red)
                }
                if !items.isEmpty, !searched {
                    List {
                        ForEach(Array(items.enumerated()), id: \.element) { index, item in
                            NavigationLink {
                                NavigationView1(item: item, index: index)
                            } label: {
                                Text("\(item.word)（\(item.furigana)）")
                                    .font(.system(size: 20))
                                    .padding(5)
                                    .contextMenu {
                                        Button("削除") {
                                            showingAlert = true
                                        }
                                    }
                                    .alert("本当に削除しますか？", isPresented: $showingAlert) {
                                        Button("キャンセル", role: .cancel) {}
                                        Button("削除", role: .destructive) {
                                            deleteItem(index: index)
                                        }
                                    }
                            }
                        }
                    }
                    .border(.black)
                }
                if searched {
                    List {
                        ForEach(meanings, id: \.self) { meaning in
                            NavigationLink {
                                NavigationView2(word: $word, meaning: meaning)
                            } label: {
                                Text(meaning)
                                    .font(.system(size: 15))
                                    .lineLimit(10)
                                    .padding(5)
                            }
                        }
                    }
                    .border(.black)
                }
            }
        }
        .padding(15)
    }
    
    private func search(word: String) -> [String] {
        var meanings: [String] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        AF.request("https://www.weblio.jp/content/\(word)").responseString { response in
            if let html = response.value, let doc = try? HTML(html: html, encoding: .utf8) {
                let kijiWrps = doc.xpath("/html/body/div[@id='base']/div[@id='wrp']/div[@id='main']/div[@id='cont']/div[@class='kijiWrp']")
                if kijiWrps.count != 0 {
                    for kijiWrp in kijiWrps {
                        let divs = kijiWrp.xpath("div[@class='kiji']/div")
                        for div in divs {
                            let Infos = div.xpath("div[contains(@class, 'Info')]")
                            if Infos.count == 0, div.className != "Wnryj" {
                                meanings.append(div.text!)
                            }
                        }
                    }
                }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return meanings
    }
    
    private func deleteItem(index: Int) {
        withAnimation {
            modelContext.delete(items[index])
        }
    }
}
