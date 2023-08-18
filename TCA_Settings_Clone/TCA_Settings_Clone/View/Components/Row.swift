import SwiftUI
import ComposableArchitecture

struct Row: View {
    let type: Cell
    @Binding var toggle: Bool
    
    init(type: Cell, toggle: Binding<Bool> = .constant(true)) {
        self.type = type
        self._toggle = toggle
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: type.imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 7).fill(type.tintColor))
            Text(type.rawValue)
            
            Spacer()
            
            if case let .detail(description) = type.style {
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Row(type: .airplaneMode)
            Row(type: .airpod)
            Row(type: .wifi)
        }
        .previewLayout(.sizeThatFits)
    }
}
