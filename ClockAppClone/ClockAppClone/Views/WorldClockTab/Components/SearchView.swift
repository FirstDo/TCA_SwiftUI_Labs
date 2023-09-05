import SwiftUI

struct SearchView: View {
  @Binding var text: String
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray.opacity(0.7))
      
      TextField("검색", text: $text)
        .tint(.orange)
        .foregroundColor(.white)
      
      if text.isEmpty == false {
        Button {
          text = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.white)
        }
      }
    }
    .padding(4)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.gray.opacity(0.3))
    )
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SearchView(text: .constant("text"))
      SearchView(text: .constant(""))
    }
    .padding()
    .preferredColorScheme(.dark)
  }
}
