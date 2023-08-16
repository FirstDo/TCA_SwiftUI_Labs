import SwiftUI

struct SettingsDetailView: View {
    let title: String
    @AppStorage("option1") var option1 = true
    @AppStorage("option2") var option2 = true
    var body: some View {
        Form {
            Section {
                Toggle("Enable option 1", isOn: $option1)
                    .toggleStyle(.automatic)
                Toggle("Enable option 2", isOn: $option2)
                    .toggleStyle(.automatic)
            }
        }
        .navigationTitle(title)
    }
}

struct SettingsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDetailView(title: "navi title")
    }
}
