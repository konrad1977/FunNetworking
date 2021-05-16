//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

struct AgeGuess: Decodable { let name: String, age: Int, count: Int }

func endpoint(from name: String) -> String { "https://api.agify.io/?name=\(name)" }

func ageGuess(from name: String) -> IO<Result<AgeGuess, Error>> {
	endpoint(from: name)
		|> URL.init(string:)
		>=> urlRequesstWithTimeout(30)
		|> requestSyncR
		<&> decodeJsonData
}

zip(
	ageGuess(from: "Anton"),
	ageGuess(from: "Carina"),
	ageGuess(from: "John")
)
.map(zip)
	.unsafeRun()
	.onSuccess { dump($0) }
	.onFailure { print($0) }

//: [Next](@next)

