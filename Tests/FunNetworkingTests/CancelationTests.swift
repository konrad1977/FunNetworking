import XCTest
@testable import FunNetworking
@testable import Funswift

final class CancelationTests: XCTestCase {

    func testCancelation() {

        let request = URL(string: "https://api.ipify.org/?format=json")
            .flatMap { URLRequest(url: $0, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10) }
        var result = requestAsyncE(request)

        XCTAssertNotNil(result.onCancel)

        let expectation = XCTestExpectation(description: "WaitingResult")

        result.run { result in
            XCTAssertTrue(result.left() is FunNetworking.NetworkRequestError)
            expectation.fulfill()
        }
        result.cancel()

        wait(for: [expectation], timeout: 2)
    }
}
