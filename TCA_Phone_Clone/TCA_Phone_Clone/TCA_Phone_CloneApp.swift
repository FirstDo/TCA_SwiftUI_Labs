import SwiftUI

@main
struct TCA_Phone_CloneApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("즐겨찾기", systemImage: "star")
                    }
                ContentView()
                    .tabItem {
                        Label("최근 통화", systemImage: "clock.fill")
                    }
                ContentView()
                    .tabItem {
                        Label("연락처", systemImage: "person.circle.fill")
                    }
                ContentView()
                    .tabItem {
                        Label("키패드", systemImage: "square.grid.3x3.fill")
                    }
                ContentView()
                    .tabItem {
                        Label("음성 사서함", systemImage: "recordingtape")
                    }
            }
        }
    }
}
