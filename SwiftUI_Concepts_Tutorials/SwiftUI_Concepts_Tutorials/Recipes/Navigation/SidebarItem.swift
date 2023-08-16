import Foundation

enum SidebarItem: Hashable {
    case all, favorites, recents
    case collection(String)
    
    var title: String {
        switch self {
        case .all:
            return "All Recipes"
        case .favorites:
            return "Favorites"
        case .recents:
            return "Recents"
        case .collection(let name):
            return name
        }
    }
}
