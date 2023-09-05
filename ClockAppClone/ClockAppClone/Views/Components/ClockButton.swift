import SwiftUI

struct ClockButton: View {
  let title: String
  let color: Color
  let action: () -> Void
  var body: some View {
    
    Button {
      action()
    } label: {
      Circle()
        .fill(color)
        .overlay(
          Circle().fill(.black)
            .padding(2)
            .overlay(
              Circle().fill(color)
                .padding(4)
            )
        )
        .overlay {
          Text(title)
            .foregroundColor(.white)
        }
    }
  }
}

struct ClockButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ClockButton(title: "시작", color: .green, action: {})
      ClockButton(title: "랩", color: .gray, action: {})
    }
    .previewLayout(.sizeThatFits)
  }
}
