import SwiftUI
import ComposableArchitecture

private enum ScreenshotsKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.userDidTakeScreenshotNotification)
                .map { _ in }
        )
    }
    
    static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.screenshots)"#, placeholder: .finished
    )
}

extension DependencyValues {
    var screenshots: @Sendable () async -> AsyncStream<Void> {
        get { self[ScreenshotsKey.self] }
        set { self[ScreenshotsKey.self] = newValue }
    }
}

struct LongLivingEffects: Reducer {
    struct State: Equatable {
        var screenshotCount = 0
    }
    
    enum Action {
        case task
        case userDidTakeScreenshotNotification
    }
    
    @Dependency(\.screenshots) var screenshots
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { send in
                for await _ in await self.screenshots() {
                    await send(.userDidTakeScreenshotNotification)
                }
            }
        case .userDidTakeScreenshotNotification:
            state.screenshotCount += 1
            return .none
        }
    }
}

struct LongLivingEffectsView: View {
    let store: StoreOf<LongLivingEffects>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("A screenshot of this screen has been taken \(viewStore.screenshotCount) times.")
                        .font(.headline)
                }
                
                Section {
                    NavigationLink(destination: detailView) {
                        Text("Navigate to another screen")
                    }
                }
            }
            .navigationTitle("Long-living effects")
            .task { await viewStore.send(.task).finish() }
        }
    }
    
    var detailView: some View {
        Text(
        """
        Take a screenshot of this screen a few times, and then go back to the previous screen to see \
        that those screenshots were not counted.
        """
        )
        .padding(.horizontal, 64)
        .navigationBarTitleDisplayMode(.inline)
    }
}
