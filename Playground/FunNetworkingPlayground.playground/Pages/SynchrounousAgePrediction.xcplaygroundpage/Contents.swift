//: [Previous](@previous)

import Foundation
import Funswift
import FunNetworking
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct AgeGuess: Decodable {
	let name: String, age: Int, count: Int
}

let endPointWithName: (String) -> String = { name in "https://api.agify.io/?name=\(name)" }
enum RequestError: Error { case invalidUrl }

func createRequest(from name: String) -> IO<Result<AgeGuess, Error>> {

	guard let url = URL(string: endPointWithName(name))
	else { return IO { .failure(RequestError.invalidUrl) } }

	return requestSyncR(URLRequest(url: url))
		.map(decodeJsonData)
}

zip(
	createRequest(from: "Mikael"),
	createRequest(from: "Jane")
)
.map(zip)
.unsafeRun()
.onSuccess { dump($0) }
.onFailure { dump($0) }


//: [Next](@next)
