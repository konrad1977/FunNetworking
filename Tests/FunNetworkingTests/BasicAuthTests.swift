import XCTest
@testable import FunNetworking
@testable import Funswift

final class BasicAuthTests: XCTestCase {

	func testBasicAuth() {

		let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

		let request: IO<Result<Data, Error>>
			= "https://jigsaw.w3.org/HTTP/Basic/"
			|> URL.init(string:)
			>=> urlRequesstWithTimeout(15)
			>=> login(username: "guest", password: "guest") |> logger
			|> requestSyncR

		dump(request.unsafeRun())
	}
}
