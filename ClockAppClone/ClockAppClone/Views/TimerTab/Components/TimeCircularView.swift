import SwiftUI

fileprivate extension Int {
  var hourAndMinuteAndSecond: String {
    let hour = String(format: "%d", self / 3600)
    let minute = String(format: "%02d", (self % 3600) / 60)
    let second = String(format: "%02d", self % 60)
    
    if hour == "0" {
      return minute + ":" + second
    } else {
      return hour + ":" + minute + ":" + second
    }
  }
  
  var hourAndMinute: String {
    let hour = String(format: "%d", self / 3600)
    let minute = String(format: "%02d", (self % 3600) / 60)
    
    return hour + ":" + minute
  }
}

struct TimeCircularView: View {
  let totalTime: Int
  let remainTime: Int
  let endTime: Int
  
  var percentage: Double {
    print(Double(remainTime) / Double(totalTime))
    return Double(remainTime) / Double(totalTime)
  }
  
  var body: some View {
    ZStack {
      Circle().stroke(Color.gray, lineWidth: 10)
      Circle().trim(from: 0.0, to: percentage).stroke(Color.orange, style: .init(lineWidth: 10, lineCap: .round))
        .animation(.linear(duration: 1), value: percentage)
        .rotationEffect(.degrees(-90))
      
      VStack(spacing: 20) {
        Text(remainTime.hourAndMinuteAndSecond)
          .font(.system(size: 60, weight: .light))
          .monospacedDigit()
        
        Label(endTime.hourAndMinute, systemImage: "bell.fill")
      }
    }
  }
}

struct TimeCircularView_Previews: PreviewProvider {
  static var previews: some View {
    TimeCircularView(totalTime: 500, remainTime: 402, endTime: 900)
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
