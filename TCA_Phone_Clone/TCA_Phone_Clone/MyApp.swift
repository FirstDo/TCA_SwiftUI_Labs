import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
  static let store = Store(initialState: ContentFeature.State(numbers: "0")) {
    ContentFeature()
  }
  
  @State private var selection = "키패드"
  
  var body: some Scene {
    WindowGroup {
      TabView(selection: $selection) {
        Color.red.opacity(0.9)
          .tabItem {
            Label("즐겨찾기", systemImage: "star")
          }
          .tag("즐겨찾기")
        Color.blue.opacity(0.9)
          .tabItem {
            Label("최근 통화", systemImage: "clock.fill")
          }
          .tag("최근 통화")
        Color.green.opacity(0.9)
          .tabItem {
            Label("연락처", systemImage: "person.circle.fill")
          }
          .tag("연락처")
        
        ContentView(store: MyApp.store)
          .tabItem {
            Label("키패드", systemImage: "square.grid.3x3.fill")
          }
          .tag("키패드")
        
        Color.orange.opacity(0.9)
          .tabItem {
            Label("음성 사서함", systemImage: "recordingtape")
          }
          .tag("음성 사서함")
      }
    }
  }
}
