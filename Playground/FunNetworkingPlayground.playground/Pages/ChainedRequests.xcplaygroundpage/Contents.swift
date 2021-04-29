//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let getIpNumberBase = "https://api.ipify.org/?format=json"
let getIpInfoUrl: (Host) -> String = { host in "https://ipinfo.io/\(host.ip)/geo" }

struct Host: Decodable { let ip: String }
struct IpInfo: Decodable {
    let ip: String, city: String, region: String, country: String, loc: String, postal: String
}

let fetchIpNumber: IO<Either<Error, Host>> = {
	getIpNumberBase
		|> URL.init(string:)
		>=> requestWithTimeout(30)
		|> requestSyncE
		<&> decodeJsonData
}()

let fetchHostInfo: (Either<Error, Host>) -> IO<Either<Error, IpInfo>> = { host in
	switch host {
	case let .right(host):
		return getIpInfoUrl(host)
			|> URL.init(string:)
			>=> requestWithTimeout(30)
			|> retry(requestSyncE, retries: 3)
			<&> decodeJsonData
	case let .left(error):
		return IO { .left(error) }
	}
}

// Syntax alternative 1
let ipInfoFetcher = fetchIpNumber >>- fetchHostInfo
dump(ipInfoFetcher.unsafeRun())

// Syntax alternative 2
//fetchIpNumber
//    .flatMap(fetchHostInfo)
//    .unsafeRun()

//: [Next](@next)
