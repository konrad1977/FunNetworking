import Foundation
import FunNetworking
import Funswift

let requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let fetchIpNumber: IO<Either<Error, Host>> = {
    "https://api.ipify.org/?format=json"
		|> URL.init(string:)
		>=> requestWithTimeout(30)
		|> requestSyncE
		<&> decodeJsonData
}()

func ipInfoFrom(_ host: Host) -> IO<Either<Error, IpInfo>> {
	"https://ipinfo.io/\(host.ip)/geo"
		|> URL.init(string:)
		>=> requestWithTimeout(30)
		|> retry(requestSyncE, retries: 3, debounce: .linear(2))
		<&> decodeJsonData
}

let fetchHostInfo: (Either<Error, Host>) -> IO<Either<Error, IpInfo>> = { result in
	switch result {
	case let .right(host):
		return ipInfoFrom(host)
	case let .left(error):
		return IO { .left(error) }
	}
}

let ipInfoFetcher = fetchIpNumber >>- fetchHostInfo
ipInfoFetcher.unsafeRun()

