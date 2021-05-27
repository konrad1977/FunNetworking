import XCTest
import Funswift
@testable import FunNetworking

final class PostTests: XCTestCase {

	func testValueLinearOneRun() throws {

		let requesIgnoreCacheTimeout = flip(requestWithCachePolicy(.reloadIgnoringCacheData))

		let request = "http://test.com"
			|> URL.init(string:)
			>=> requesIgnoreCacheTimeout(10)
			>=> post(["SomeValue" : "1"])
		XCTAssertEqual(request?.httpMethod, "POST")

		let acceptHeader = try XCTUnwrap(request?.value(forHTTPHeaderField: "Accept"))
		XCTAssertEqual(acceptHeader, "application/json")

		let contentType = try XCTUnwrap(request?.value(forHTTPHeaderField: "Content-Type"))
		XCTAssertEqual(contentType, "application/json")
	}
}
