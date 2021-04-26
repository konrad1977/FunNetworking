//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct AgeGuess: Decodable {
	let name: String, age: Int, count: Int
}

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

func logStep<T: Any>(_ value: T) -> T { dump(value); return value }

func endpoint(from name: String) -> String { "https://api.agify.io/?name=\(name)" }

func ageGuess(from name: String) -> IO<Result<AgeGuess, Error>> {
	endpoint(from: name)
		|> URL.init(string:)
		>=> urlRequesstWithTimeout(30)
		|> syncRequest
		<&> decodeData
}

zip(
	ageGuess(from: "Anton"),
	ageGuess(from: "Jane"),
	ageGuess(from: "John")
)
.map(zip)
	.unsafeRun()
	.onSuccess { dump($0) }
	.onFailure { print($0) }

//: [Next](@next)

