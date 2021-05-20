//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift


let requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let getIpInfoUrl: (Host) -> String = { host in "https://ipinfo.io/\(host.ip)/geo" }

struct Host: Decodable { let ip: String }
struct IpInfo: Decodable {
    let ip: String, city: String, region: String, country: String, loc: String, postal: String
}

let fetchIpNumber: IO<Either<Error, Host>> = {
    "https://api.ipify.org/?format=json"
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
            |> retry(requestSyncE, retries: 3, debounce: .linear(2))
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


func curry2<A, B, C>(
    _ f: @escaping (A, B) -> C)
-> (A) -> (B) -> C {
    return { a in { b in f(a,b) } }
}

curry2(String.init(data:encoding:))
let stringFromDataWithEncoding = flip(curry2(String.init(data:encoding:)))

stringFromDataWithEncoding(.utf8)


func pipe<A, B>(_ value: A, _ f: (A) -> B) -> B {
    f(value)
}

