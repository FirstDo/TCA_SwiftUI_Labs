import SwiftUI
import ComposableArchitecture

struct FinalScreen: Reducer {
    
}

struct FinalScreenView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FinalScreenView_Previews: PreviewProvider {
    static var previews: some View {
        FinalScreenView()
    }
}


struct APIModel: Codable, Equatable {
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let job: String
}

struct LabelledRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content
    
    init(
        _ label: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            content()
        }
        .contentShape(Rectangle())
    }
}
