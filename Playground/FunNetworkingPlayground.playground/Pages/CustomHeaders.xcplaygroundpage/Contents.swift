//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))
let gitIgnoreTemplates = "https://api.github.com/gitignore/templates"

let request: IO<Result<[String], Error>>
	= gitIgnoreTemplates
	|> URL.init(string:)
	>=> urlRequesstWithTimeout(15)
	>=> setHeader("application/vnd.github.v3+json", for: "Accept")
	|> requestSyncR
	<&> decodeJsonData

dump(request.unsafeRun())

//: [Next](@next)
