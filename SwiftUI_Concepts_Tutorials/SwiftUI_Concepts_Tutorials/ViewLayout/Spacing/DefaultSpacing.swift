import SwiftUI

struct DefaultSpacing: View {
    @ScaledMetric var trainCarSpace = 5
    var body: some View {
        Text("Default Spacing")
        HStack(spacing: .zero) {
            TrainCar(.rear)
            TrainCar(.middle)
                .font(.largeTitle)
                .opacity(0)
                .background(Color.blue)
            TrainCar(.front)
        }
        TraintTrack()
    }
}

struct DefaultSpacing_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DefaultSpacing()
        }
    }
}
