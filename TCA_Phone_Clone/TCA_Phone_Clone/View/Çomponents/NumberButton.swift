import SwiftUI

struct NumberButton: View {
  let number: Number?
  let action: () -> Void
  
  var body: some View {
    if let number {
      Button {
        action()
      } label: {
        VStack {
          Text(number.rawValue)
            .font(.largeTitle)
          if let detail = number.alphabet {
            Text(detail)
              .font(.caption2)
          }
        }
        .padding()
        .frame(width: 80, height: 80)
        .background(Color.black.opacity(0.15), in: Circle())
      }
      .tint(.black)
    } else {
      Button {
        action()
      } label: {
        Image(systemName: "phone.fill")
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.white)
          .frame(width: 80, height: 80)
          .background(.green, in: Circle())
      }
    }
  }
}

struct NumberButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      NumberButton(number: .one, action: {})
      NumberButton(number: .hash, action: {})
      NumberButton(number: .star, action: {})
      NumberButton(number: .seven, action: {})
    }
  }
}
