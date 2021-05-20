import XCTest
@testable import FunNetworking
@testable import Funswift

final class CancelationTests: XCTestCase {

    func testCancelation() {

        let request = URL(string: "https://api.ipify.org/?format=json")
            .flatMap { URLRequest(url: $0, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10) }
        let result = requestAsyncE(request)

        XCTAssertTrue(result.canCancel)
        XCTAssertNotNil(result.onCancel)

        let expectation = XCTestExpectation(description: "WaitingResult")
        result.cancel()

        result.run { result in
            XCTAssertTrue(result.left() is FunNetworking.NetworkRequestError)
            expectation.fulfill()
        }

        debugPrint(result)
        wait(for: [expectation], timeout: 2)
    }
}
