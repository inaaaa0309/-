//
//  WordScanner.swift
//  iOS
//
//  Created by 稲谷究 on 2024/07/14.
//

import VisionKit
import SwiftUI

struct WordScanner: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    @Binding var word: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(recognizedDataTypes: [.text()],
                                                   qualityLevel: .balanced,
                                                   recognizesMultipleItems: true,
                                                   isPinchToZoomEnabled: true,
                                                   isHighlightingEnabled: true)
        
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isScanning {
            do {
                try uiViewController.startScanning()
            } catch(let error) {
                print(error)
            }
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: WordScanner
        
        init(_ parent: WordScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.word = text.transcript
            default:
                break
            }
        }
    }
}
