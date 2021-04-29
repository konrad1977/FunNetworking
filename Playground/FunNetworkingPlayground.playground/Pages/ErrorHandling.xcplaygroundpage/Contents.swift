//: [Previous](@previous)

import Foundation

import Foundation
import FunNetworking
import Funswift

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let getIpNumberBase = "ttps://api.ipify.org/?format=json"
let getIpInfoUrl: (Host) -> String = { host in "https://ipinfo.io/\(host.ip)/geo" }

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
		|> syncRequest
		<&> decodeJsonData
}()

fetchIpNumber
	.unsafeRun()
	.onLeft(handleError)
	.onRight({ dump($0) })

//: [Next](@next)
