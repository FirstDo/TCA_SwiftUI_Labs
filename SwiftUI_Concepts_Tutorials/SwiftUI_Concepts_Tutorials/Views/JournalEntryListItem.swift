import SwiftUI

struct JournalEntryListItem: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            DateView(date: entry.createdDate)
            Text(entry.text)
                .lineLimit(2)
        }
    }
}

struct JournalEntryListItem_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryListItem(entry: .init(createdDate: .now, text: "dummy"))
    }
}
