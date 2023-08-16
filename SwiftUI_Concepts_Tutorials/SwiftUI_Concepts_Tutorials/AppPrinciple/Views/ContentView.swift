import SwiftUI

struct ContentView: View {
    @StateObject var journal = Journal()
    
    var body: some View {
        NavigationStack {
            List(journal.entries) { entry in
                NavigationLink(value: entry) {
                    JournalEntryListItem(entry: entry)
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryView(entry: entry)
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem {
                    Button {
                        journal.addSampleEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
