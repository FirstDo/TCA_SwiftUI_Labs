import XCTest
import ComposableArchitecture

@testable import ComposableTutorial

@MainActor
final class CounterTests: XCTestCase {
    
    var store: TestStoreOf<CounterFeature>!
    let clock = TestClock()
    
    override func setUpWithError() throws {
        store = TestStore(
            initialState: .init(),
            reducer: { CounterFeature() },
            withDependencies: {
                $0.continuousClock = clock
                $0.numberFact.fetch = {"\($0) is a good number."}
            }
        )
    }
    
    override func tearDownWithError() throws {
        store = nil
    }
    
    func test_증가버튼() async {
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
    }
    
    func test_감소버튼() async {
        await store.send(.decrementButtonTapped) {
            $0.count = -1
        }
    }
    
    // MARK: - Testing Effects
    
    func test_타이머() async {
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        
        await clock.advance(by: .seconds(3))
        
        await store.receive(.timerTick) { $0.count = 1 }
        await store.receive(.timerTick) { $0.count = 2 }
        await store.receive(.timerTick) { $0.count = 3 }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    func test_숫자팩트테스트() async {
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.factResponse("0 is a good number."), timeout: .seconds(1)) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
