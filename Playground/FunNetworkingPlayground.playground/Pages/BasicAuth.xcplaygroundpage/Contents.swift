//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))
let basicAuthUrl = "https://jigsaw.w3.org/HTTP/Basic/"

let request: Deferred<Result<Data, Error>>
	= basicAuthUrl
	|> URL.init(string:)
	>=> urlRequesstWithTimeout(15)
	>=> authorization(.basic(username: "guest", password: "guest")) |> logger
	|> requestAsyncR

request.run { result in
	dump(result)
}

//: [Next](@next)
