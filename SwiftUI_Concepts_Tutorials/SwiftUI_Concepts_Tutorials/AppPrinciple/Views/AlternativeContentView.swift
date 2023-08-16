import SwiftUI

struct AlternativeContentView: View {
    @StateObject private var journal = Journal()
    @State private var selectedEntry: JournalEntry?
    
    
    var body: some View {
        NavigationSplitView {
            List(journal.entries, selection: $selectedEntry) { entry in
                NavigationLink(value: entry) {
                    JournalEntryListItem(entry: entry)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem {
                    Button {
                        journal.addSampleEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            DetailView(selectedEntry: $selectedEntry)
        }
    }
}

struct AlternativeContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlternativeContentView()
    }
}
