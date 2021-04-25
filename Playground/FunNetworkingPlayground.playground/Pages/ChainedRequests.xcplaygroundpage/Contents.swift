//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift

func logStep<T: Any>(_ value: T) -> T { dump(value); return value }

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let getIpNumberBase = "https://api.ipify.org/?format=json"
let getIpInfoUrl: (Host) -> String = { host in "https://ipinfo.io/\(host.ip)/geo" }

func decodeData<T: Decodable>(
    result: Result<Data, Error>
) -> Result<T, Error> {
    Result(catching: { try JSONDecoder().decode(T.self, from:result.get()) } )
}

struct IpInfo: Decodable {
    let ip: String, city: String, region: String, country: String, loc: String, postal: String
}

struct Host: Decodable { let ip: String }

func fetchMyIpNumber() -> IO<Result<Host, Error>> {
    getIpNumberBase
        |> URL.init(string:)
        >=> urlRequesstWithTimeout(30)  |> logStep
        |> retry(syncRequest)(3)        |> logStep
        <&> decodeData
}

func fetchIpNumberFrom(host: Result<Host, Error>) -> IO<Result<IpInfo, Error>> {
    switch host {
    case let .success(host):
        return getIpInfoUrl(host)
            |> URL.init(string:)
            >=> urlRequesstWithTimeout(30)
            |> retry(syncRequest, retries: 3)
            <&> decodeData
    case let .failure(error):
        return IO { .failure(error) }
    }
}

let ipInfoFetcher = fetchMyIpNumber() >>- fetchIpNumberFrom
dump(ipInfoFetcher.unsafeRun())

//: [Next](@next)
