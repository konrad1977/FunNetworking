//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift

func logStep<T: Any>(_ value: T) -> T { dump(value); return value }

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))
struct Host: Decodable { let ip: String }

let getIpNumberBase = "https://api.ipify.org/?format=json"
let getIpInfoUrl: (Host) -> String = { host in "https://ipinfo.io/\(host.ip)/geo" }

struct IpInfo: Decodable {
    let ip: String, city: String, region: String, country: String, loc: String, postal: String
}

extension String: Error {}

func fetchMyIpNumber() -> IO<Either<Error, Host>> {
    getIpNumberBase
        |> URL.init(string:)
        >=> urlRequesstWithTimeout(30)
        |> syncRequest 
        <&> decodeJsonData |> logStep
}

func fetchExtendedInformationFrom(host: Either<Error, Host>) -> IO<Either<Error, IpInfo>> {
    switch host {
    case let .right(host):
        return getIpInfoUrl(host)
            |> URL.init(string:)
            >=> urlRequesstWithTimeout(30)
            |> retry(syncRequest, retries: 3)
            <&> decodeJsonData
    case let .left(error):
        return IO { .left(error) }
    }
}


// Syntax alternative 1
let ipInfoFetcher = fetchMyIpNumber() >>- fetchExtendedInformationFrom
dump(ipInfoFetcher.unsafeRun())

// Syntax alternative 2
//fetchMyIpNumber()
//    .flatMap(fetchExtendedInformationFrom)
//    .unsafeRun()

//: [Next](@next)