//: [Previous](@previous)

import Foundation

import Foundation
import FunNetworking
import Funswift

struct Host: Decodable { let ip: String }

func handleError(error: Error) {
	switch error {
	case let NetworkRequestError.failed(err):
		print(err)
	case NetworkRequestError.invalidRequest:
		print("Invalid request")
	case let NetworkRequestError.invalidResponse(code):
		print("Invalid response code: \(code)")
	default:
		print("An error occured \(error)")
	}
}

let fetchIpNumber: IO<Either<Error, Host>> = {
	Optional<URLRequest>.none
		|> requestSyncE
		<&> decodeJsonData
}()

fetchIpNumber
	.unsafeRun()
	.onLeft(handleError)
	.onRight({ dump($0) })

//: [Next](@next)
