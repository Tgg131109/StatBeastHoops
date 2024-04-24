//
//  ContentLoaderView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/15/24.
//

import SwiftUI

struct ContentLoaderView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ShimmerEffectBox: View {
    private var gradientColors = [
        Color(uiColor: UIColor.systemGray5),
        Color(uiColor: UIColor.clear),
        Color(uiColor: UIColor.systemGray5)
    ]
    
    @State var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State var endPoint: UnitPoint = .init(x: 0, y: -0.2)
    
    var body: some View {
        ZStack {
            
            LinearGradient (colors: gradientColors, startPoint: startPoint, endPoint: endPoint)
                .onAppear { withAnimation (.easeInOut (duration: 1)
                    .repeatForever (autoreverses: false)) {
                        startPoint = .init(x: 1, y: 1)
                        endPoint = .init(x: 2.2, y: 2.2)
                    }
                }
            
            Color.clear.background(.ultraThinMaterial)
        }
    }
}

#Preview {
//    ContentLoaderView()
    ShimmerEffectBox()
}
