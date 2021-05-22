import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let urlRequestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let weatherDecoder: JSONDecoder = {
	let jsonDecoder = JSONDecoder()
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd"
	jsonDecoder.dateDecodingStrategy = .formatted(formatter)
	jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	return jsonDecoder
}()

let networkPathForId: (Int) -> (String) -> String = {
	id in { base in base + "location/\(id)" }
}

func weatherInfo(for id: Woeid) -> Deferred<Result<Weather, Error>> {
    "https://www.metaweather.com/api/"
		|> networkPathForId(id.rawValue) 	                        // |> logger
		|> URL.init(string:) 				                        //|> logger
		>=> urlRequestWithTimeout(30) 		                        //|> logger
        |> retry(requestAsyncR, retries: 3, debounce: .linear(2))   //|> logger
		<&> decodeJsonData(with: weatherDecoder)
}

zip(
    weatherInfo(for: .stockholm),
    weatherInfo(for: .london),
    weatherInfo(for: .copenhagen)
)
.map(zip)
.run { result in
    //dump(result)
}

