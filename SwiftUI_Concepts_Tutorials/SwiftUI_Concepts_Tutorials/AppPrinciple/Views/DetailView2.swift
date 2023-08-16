import SwiftUI

struct DetailView2: View {
    @Binding var selectedEntry: JournalEntry?
    
    var body: some View {
        if let selectedEntry {
            JournalEntryView(entry: selectedEntry)
        } else {
            Text("Select a journal entry")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView2(selectedEntry: .constant(.init(text: "dummy")))
    }
}
