import SwiftUI

struct DeleteButton: View {
  let action: () -> Void
  
  var body: some View {
    Button {
      action()
    } label: {
      Image(systemName: "delete.left.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 30)
        .foregroundStyle(.black, .black.opacity(0.15))
    }
  }
}

struct DeleteButton_Previews: PreviewProvider {
  static var previews: some View {
    DeleteButton(action: {})
      .previewLayout(.sizeThatFits)
  }
}
