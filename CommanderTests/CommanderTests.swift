import Testing
@testable import Cygnet

struct CygnetTests {

    @Test func testLoadingState() {
        let state = LoadingState.loading
        #expect(state == .loading)
    }

    @Test func testLoadingStateLoaded() {
        let state = LoadingState.loaded
        #expect(state == .loaded)
    }

    @Test func testLoadingStateFailed() {
        let state = LoadingState.failed
        #expect(state == self.failedState())
    }

    func failedState() -> LoadingState {
        return .failed
    }

}
