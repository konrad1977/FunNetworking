//: [Previous](@previous)

import Foundation
import Funswift
import FunNetworking
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct AgeGuess: Decodable {
	let name: String, age: Int, count: Int
}

func endpoint(from name: String) -> String { "https://api.agify.io/?name=\(name)" }
enum RequestError: Error { case invalidUrl }

func createRequest(from name: String) -> IO<Result<AgeGuess, Error>> {

	guard let url = URL(string: endpoint(from: name))
	else { return IO { .failure(RequestError.invalidUrl) } }

	return syncRequest(URLRequest(url: url))
		.map(decodeJsonData)
}

zip(
	createRequest(from: "Mikael"),
	createRequest(from: "Mikael")
)
.map(zip)
.unsafeRun()
.onSuccess { dump($0) }
.onFailure { dump($0) }

//: [Next](@next)
