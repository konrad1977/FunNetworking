import XCTest
@testable import FunNetworking
@testable import Funswift

final class RetryTests: XCTestCase {

	enum TestError: Error { case custom }

	func failingResultFunction(value: Int) -> Result<Int, Error> { .failure(TestError.custom) }

	func testRetryForFailingResultLinear() {

		let resultFunc = retry(failingResultFunction, retries: 3, debounce: .linear(0.5))

		let expectation = XCTestExpectation(description: "WaitingDebounce")

		switch resultFunc(10) {
		case .failure:
			expectation.fulfill()
		case .success:
			XCTAssertTrue(true)
		}

		wait(for: [expectation], timeout: 1.550)
	}

	func testRetryForFailingResultExponential() {

		let resultFunc = retry(failingResultFunction, retries: 3, debounce: .exponential(0.5))

		let expectation = XCTestExpectation(description: "WaitingDebounce")

		switch resultFunc(10) {
		case .failure:
			expectation.fulfill()
		case .success:
			XCTAssertTrue(true)
		}

		wait(for: [expectation], timeout: 1.550)
	}
}
