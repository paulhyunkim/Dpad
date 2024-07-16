//
//  Color.swift
//  Dpad
//
//  Created by Paul Kim on 10/14/22.
//

import SwiftUI

struct Style {
    
    struct Color {
        
        static let background = SwiftUI.Color("BackgroundColor")
        static let accent = SwiftUI.Color("AccentColor")
        static let textPrimary = SwiftUI.Color("PrimaryTextColor")
        static let textSecondary = SwiftUI.Color("SecondaryTextColor")
    }
    
    enum Text {
        case title1
        case title2
        case title3
        case subtitle
        case subtitleSemibold
        case button
        case body
        case caption
        case captionSemibold
        
        var fontSize: CGFloat {
            switch self {
            case .title1:
                return 34
            case .title2:
                return 28
            case .title3:
                return 22
            case .subtitle,
                 .subtitleSemibold:
                return 14
            case .button,
                 .body:
                return 12
            case .caption,
                 .captionSemibold:
                return 12
            }
        }
        
        var fontWeight: Font.Weight {
            switch self {
            case .title1,
                 .title2,
                 .title3:
                return .bold
            case .subtitle:
                return .regular
            case .subtitleSemibold:
                return .semibold
            case .button:
                return .semibold
            case .body:
                return .regular
            case .caption:
                return .regular
            case .captionSemibold:
                return .semibold
            }
        }
        
        // Line Spacing = (Line Height - Font Size) / 2
        var lineSpacing: CGFloat {
            switch self {
            case .title1:
                return 4
            case .title2:
                return 3
            case .title3:
                return 3
            case .subtitle,
                 .subtitleSemibold:
                return 4
            case .button:
                return 3
            case .body:
                return 2
            case .caption,
                 .captionSemibold:
                return 2
            }
        }
        
        var font: Font {
            return Font.system(size: fontSize, weight: fontWeight)
        }
    }
    
}


struct TextStyleModifier: ViewModifier {
    
    let style: Style.Text
    
    init(_ style: Style.Text) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
    }

}

extension View {
    
    func textStyle(_ style: Style.Text) -> some View {
        modifier(TextStyleModifier(style))
    }
    
}



