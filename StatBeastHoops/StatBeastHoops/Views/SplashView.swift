//
//  SplashView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/16/24.
//

import SwiftUI

struct SplashView: View {
    @StateObject var apiManager : DataManager
    
    var body: some View {
        VStack {
            if apiManager.isTaskRunning {
                loadingView
//                IndeterminateProgressView()
//                ProgressView().progressViewStyle(.linear)
                
//                ProgressView(value: apiManager.progress) {
//                       Text("Label")
//                   } currentValueLabel: {
//                       Text("Current Value Label: \(apiManager.progress)")
//                   }
                
                
//                ProgressView("Fetching data...", value: apiManager.progress)
////                    .progressViewStyle(LinearProgressViewStyle())
//                    .padding()
            } else {
//                TabView {
//                    HomeView(apiManager: apiManager)
//                        .tabItem {
//                            Label("Home", systemImage: "list.dash")
//                        }
//                    
//                    CompareView(apiManager: apiManager)
//                        .tabItem {
//                            Label("Compare", systemImage: "square.and.pencil")
//                        }
//                    
//                    FavoritesView()
//                        .tabItem {
//                            Label("Favorites", systemImage: "heart.text.square")
//                        }
//                    
//                    PlayersView(apiManager: apiManager)
//                        .tabItem {
//                            Label("Players", systemImage: "person.3")
//                        }
//                    
//                    TeamsView(apiManager: apiManager)
//                        .tabItem {
//                            Label("Teams", systemImage: "basketball")
//                        }
//                }
            }
        }.onAppear(perform: {   Task{
            _ = await apiManager.getAllPlayers()
        } })
    }
    
    var loadingView: some View {
        VStack {
            Text("StatBeast | Hoops").font(.largeTitle).fontWeight(.black)
            ProgressView().padding().tint(LinearGradient(colors: [Color.blue, Color.red], startPoint: .top, endPoint: .bottom)).controlSize(.large)
//            ProgressView().padding().controlSize(.extraLarge).tint(LinearGradient(colors: [Color.blue, Color.red], startPoint: .bottomLeading, endPoint: .topTrailing))
//            LinearGradient(colors: [Color.pink, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing)
//            ProgressView().padding().controlSize(.extraLarge).progressViewStyle(LinearProgressViewStyle(tint: Color.yellow))
            Text("Gathering data...").italic().bold()//.foregroundStyle(.background)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.ultraThinMaterial).foregroundStyle(
            LinearGradient(
                colors: [.teal, .primary],
                startPoint: .topLeading,
                endPoint: .bottom
            )
        )
    }
}

//struct WidthPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = max(value, nextValue())
//    }
//}
//
//private struct ReadWidthModifier: ViewModifier {
//    private var sizeView: some View {
//        GeometryReader { geometry in
//            Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
//        }
//    }
//
//    func body(content: Content) -> some View {
//        content.background(sizeView)
//    }
//}
//
//extension View {
//    func readWidth() -> some View {
//        self
//            .modifier(ReadWidthModifier())
//    }
//}

#Preview {
    SplashView(apiManager: DataManager())
}
