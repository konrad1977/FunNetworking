import XCTest
@testable import FunNetworking

final class UnthrowingTests: XCTestCase {

    enum CustomError: Error {
        case somethingWentWrong
    }

    func functionThatThrows() throws -> Int {
        throw CustomError.somethingWentWrong
    }

    func testExample() {
        var thrownError: Error?

        // Capture the thrown error using a closure
        XCTAssertThrowsError(try functionThatThrows()) {
            thrownError = $0
        }

        XCTAssertTrue(
            thrownError is CustomError,
            "Unexpected error type: \(type(of: thrownError))"
        )

        let result: Result<Int, Error> = unThrow(try functionThatThrows())
        switch result {
        case let .failure(error):
            XCTAssertTrue(
                error is CustomError,
                "Unexpected error type: \(type(of: thrownError))"
            )
        case .success:
            XCTAssert(true)
        }
    }
}
