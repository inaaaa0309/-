//
//  ModalView.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import Alamofire
import Kanna
import SwiftData
import SwiftUI

struct ModalView: View {
    @Binding var showingModal: Bool
    
    @Environment(\.modelContext) private var modelContextS
    @Query(sort: \Item.addedAt, order: .reverse) private var items: [Item]
    
    @State private var word: String = ""
    @State private var meanings: [String] = []
    
    @FocusState private var wordFocus: Bool
    
    @State private var isScanning: Bool = false
    @State var image = UIImage()
    
    @State private var searched: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if meanings.isEmpty {
                    Spacer()
                }
                HStack {
                    HStack {
                        TextField("語彙の意味を検索", text: $word)
                            .multilineTextAlignment(.leading)
                            .submitLabel(.search)
                            .font(.system(size: 30))
                            .focused($wordFocus)
                            .onChange(of: word) {
                                if searched {
                                    searched = false
                                }
                                if !meanings.isEmpty {
                                    meanings = []
                                }
                            }
                            .onSubmit {
                                if !word.isEmpty {
                                    DispatchQueue.global().async {
                                        meanings = search(word: word)
                                        searched = true
                                    }
                                }
                            }
                        Button {
                            word = ""
                            isScanning = true
                        } label: {
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        }
                        .fullScreenCover(isPresented: $isScanning) {
                            VStack {
                                WordScanner(isScanning: $isScanning, word: $word)
                                Text(word)
                                .frame(height: 100)
                                .multilineTextAlignment(.center)
                                HStack {
                                    Button("キャンセル") {
                                        word = ""
                                        isScanning = false
                                    }
                                    Spacer()
                                    Button("完了") {
                                        isScanning = false
                                    }
                                    .disabled(word.isEmpty)
                                }
                                .padding()
                            }
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 2)
                            .padding(-5)
                    }
                    .padding(.trailing, 10)
                    Button {
                        wordFocus = false
                        DispatchQueue.global().async {
                            meanings = search(word: word)
                            searched = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .disabled(word.isEmpty)
                }
                .padding(meanings.isEmpty ? .horizontal : .all, 20)
            }
            if searched, meanings.isEmpty {
                VStack {
                    Text("その語彙の意味はヒットしませんでした")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Spacer()
                }
            } else {
                List(meanings, id: \.self) { meaning in
                    NavigationLink {
                        ModalNavigationView(word: word, meaning: meaning, showingModal: $showingModal)
                    } label: {
                        Text(meaning)
                            .lineLimit(10)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
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
}
