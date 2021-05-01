import XCTest
@testable import FunNetworking
@testable import Funswift

final class RetryTests: XCTestCase {

	enum TestError: Error { case custom }

	func failingResultFunction(value: Int) -> Result<Int, Error> { .failure(TestError.custom) }

	func testRetryForFailingResultLinear() {


		let expectation = XCTestExpectation(description: "WaitingDebounce")

        DispatchQueue.global().async {
            let resultFunc = retry(self.failingResultFunction, retries: 3, debounce: .linear(0.5))

            switch resultFunc(10) {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTAssertTrue(true)
            }
        }
		wait(for: [expectation], timeout: 1.550)
	}

	func testRetryForFailingResultExponential() {

		let expectation = XCTestExpectation(description: "WaitingDebounce")

        DispatchQueue.global().async {
            let resultFunc = retry(self.failingResultFunction, retries: 3, debounce: .exponential(0.5))

            switch resultFunc(10) {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTAssertTrue(true)
            }
        }
        wait(for: [expectation], timeout: 4)
	}
}
