import SwiftUI

struct SettingsView: View {
    var body: some View {
        #if os(macOS)
        SettingsInTabView
        #else
        SettingsINNavigationStack
        #endif
    }
    
    enum Settings: String, CaseIterable {
        case account = "Account"
        case sync = "Sync"
        case general = "General"
        case appIcon =  "App icon"
        
        var image: String {
            switch self {
            case .account:
                return "person.crop.circle"
            case .sync:
                return "cloud"
            case .general:
                return "gear"
            case .appIcon:
                return "app"
            }
        }
    }
    
    var SettingsINNavigationStack: some View {
        NavigationStack {
            List {
                ForEach([Settings.account, Settings.sync], id: \.self) { setting in
                    NavigationLink {
                        SettingsDetailView(title: setting.rawValue)
                    } label: {
                        Label(setting.rawValue, systemImage: setting.image)
                    }
                }
                
                Section {
                    ForEach([Settings.general, Settings.appIcon], id: \.self) { setting in
                        NavigationLink {
                            SettingsDetailView(title: setting.rawValue)
                        } label: {
                            Label(setting.rawValue, systemImage: setting.image)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    var SettingsInTabView: some View {
        TabView {
            ForEach(Settings.allCases, id: \.self) { item in
                SettingsDetailView(title: item.rawValue)
                    .tabItem {
                        Label(item.rawValue, systemImage: item.image)
                    }
                    .tag(item)
            }
        }
        .frame(width: 375, height: 150)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
