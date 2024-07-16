//
//  SizeReader.swift
//  Dpad
//
//  Created by Paul Kim on 12/8/22.
//

import SwiftUI

struct SizeReader: ViewModifier {
    
    @Binding var size: CGSize
//    @Environment(\.windowSize) var windowSize
//    @State var windowSize: CGSize
    
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.size) { newValue in
                            self.size = newValue
//                            print(newValue)
                            
//                            windowSize = newValue
                        }
//                        .environment(\.windowSize, size)
                }
            }
    }
    
}

extension View {
    
    func trackSize(size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
    }
    
}

struct ViewSizeKey: EnvironmentKey {
    
    static var defaultValue: CGSize = .zero
    
}

extension EnvironmentValues {
    
    var windowSize: CGSize {
        get { self[ViewSizeKey.self] }
        set { self[ViewSizeKey.self] = newValue }
    }
    
}
