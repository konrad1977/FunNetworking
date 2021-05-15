import XCTest
@testable import FunNetworking
@testable import Funswift

final class BasicAuthTests: XCTestCase {

	func testBasicAuth() throws {

		let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

		let request = "https://jigsaw.w3.org/HTTP/Basic/"
			|> URL.init(string:)
			>=> urlRequesstWithTimeout(15)
			>=> authorization(.basic(username: "guest", password: "guest"))


		let authorization = try XCTUnwrap(request?.value(forHTTPHeaderField:"authorization"))
		XCTAssertEqual(authorization, "Basic Z3Vlc3Q6Z3Vlc3Q=")
	}
}
