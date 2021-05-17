//: [Previous](@previous)

import Foundation
import Funswift
import FunNetworking
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct AgeGuess: Decodable {
	let name: String, age: Int, count: Int
}

func createRequest(from name: String) -> IO<Result<AgeGuess, Error>> {

    let request = URL(string: "https://api.agify.io/?name=\(name)")
        .flatMap { URLRequest(url: $0, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10) }

    let requestWithRetry = retry(requestSyncR, retries: 3, debounce: .linear(3))
    return requestWithRetry(request).map(decodeJsonData)
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
