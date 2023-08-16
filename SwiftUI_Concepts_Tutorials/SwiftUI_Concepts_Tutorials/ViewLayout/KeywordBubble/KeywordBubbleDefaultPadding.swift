import SwiftUI

struct KeywordBubbleDefaultPadding: View {
    let keyword: String
    let symbol: String
    @ScaledMetric(relativeTo: .title) var paddingWidth = 14.5
    
    var body: some View {
        Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding(paddingWidth)
            .background(
                Capsule()
                    .fill(.purple.opacity(0.75))
            )
    }
}

struct KeywordBubbleDefaultPadding_Previews: PreviewProvider {
    static let keywords = ["chives", "fern-leaf lavender"]
    static var previews: some View {
        VStack {
            ForEach(keywords, id: \.self) { word in
                KeywordBubbleDefaultPadding(keyword: word, symbol: "leaf")
            }
        }
    }
}
