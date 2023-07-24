import Foundation
import ComposableArchitecture

struct FactClient {
    var fetch: @Sendable (Int) async throws -> String
}

extension DependencyValues {
    var factClient: FactClient {
        get { self[FactClient.self] }
        set { self[FactClient.self] = newValue }
    }
}

extension FactClient: DependencyKey {
    static let liveValue = FactClient(
        fetch: {
            number in
            try await Task.sleep(for: .seconds(1))
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "http://numbersapi.com/\(number)/trivia")!)
            return String(decoding: data, as: UTF8.self)
        }
    )
    
    
    static let testValue = FactClient(
        fetch: unimplemented("Fetch")
    )
}
