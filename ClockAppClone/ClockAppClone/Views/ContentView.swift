import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      NavigationStack {
        WorldClockView()
      }
      .tabItem {
        Label("세계 시계", systemImage: "globe")
      }
      
      NavigationStack {
        AlarmView()
      }
      .tabItem {
        Label("알람", systemImage: "alarm.fill")
      }
      
      StopWatchView()
        .tabItem {
          Label("스톱워치", systemImage: "stopwatch.fill")
        }
        .toolbar(.hidden, for: .navigationBar)
      TimerView()
        .tabItem {
          Label("타이머", systemImage: "timer")
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    .tint(.orange)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}
