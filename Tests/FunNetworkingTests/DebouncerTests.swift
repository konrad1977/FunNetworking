import XCTest
@testable import FunNetworking

final class DebouncerTests: XCTestCase {

    func testValueLinearOneRun() {
        let result = Debounce.linear(10).run()
        XCTAssertEqual(10, result.value)
    }

    func testValueLinearExpOneRun() {
        let result = Debounce.exponential(10).run()
        XCTAssertEqual(20, result.value)

        XCTAssertEqual(40, result.run().value)
    }
}
