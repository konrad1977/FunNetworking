import Foundation
import Funswift
import FunNetworking
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct AgeGuess: Decodable {
    let name: String, age, count: Int
}

func createAgifyRequest(for name: String) -> URLRequest? {
    URL(string: "https://api.agify.io/?name=\(name)")
    .flatMap {
        URLRequest(url: $0, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
    }
}

func ageGuessWithRetryFrom(_ request: URLRequest?) -> IO<Result<AgeGuess, Error>> {
    let requestWithRetry = retry(requestSyncR, retries: 3, debounce: .linear(3))
    return requestWithRetry(request).map(decodeJsonData)
}

func ageGuessFrom(_ request: URLRequest?) -> IO<Result<AgeGuess, Error>> {
    requestSyncR(request)
        .map(decodeJsonData)
}

zip(
    ageGuessWithRetryFrom(createAgifyRequest(for: "Mikael")),
    ageGuessFrom(createAgifyRequest(for: "Jane"))
)
.map(zip)
.unsafeRun()
.onSuccess { dump($0) }
.onFailure { dump($0) }

