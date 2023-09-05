import SwiftUI

struct WorldClockRow: View {
  let item: WorldClockItem
  let isEdit: Bool
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 5) {
        Text("오늘,\(item.diff)시간")
          .foregroundColor(.gray)
        Text(item.cityName)
          .font(.system(size: 30))
          .bold()
          .foregroundColor(.white)
      }
      
      Spacer()
      
      if !isEdit {
        Text(item.time, format: .dateTime
          .hour(.conversationalTwoDigits(amPM: .omitted))
          .minute()
        )
        .monospacedDigit()
        .foregroundColor(.white)
        .font(.system(size: 50))
      }
    }
    .background(Color.black)
  }
}

struct WorldClockRow_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      WorldClockRow(item: .서울, isEdit: true)
      WorldClockRow(item: .서울, isEdit: false)
    }
    .background(Color.black)
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
  }
}
