import SwiftUI

struct JournalEntryView: View {
    let entry: JournalEntry
    
    var title: String {
        entry.createdDate.formatted(
            Date.FormatStyle()
                .weekday(.abbreviated)
                .month(.abbreviated)
                .day()
                .year()
        )
    }
    
    var body: some View {
        ScrollView {
            Text(entry.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        #if os(iOS)
        .navigationTitle(title)
        #elseif os(macOS)
        .navigationSubtitle(title)
        #endif
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(entry: .init(createdDate: .now, text: "dummy date"))
    }
}
