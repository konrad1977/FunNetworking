import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let urlRequestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

func ageGuess(from name: String) -> IO<Result<Guess, Error>> {
	"https://api.agify.io/?name=\(name)"
		|> URL.init(string:)
		>=> urlRequestWithTimeout(30)
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
