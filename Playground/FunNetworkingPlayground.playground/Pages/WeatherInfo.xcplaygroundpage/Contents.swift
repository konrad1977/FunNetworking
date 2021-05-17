//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

enum Woeid: Int {
	case copenhagen = 554890
	case london = 44418
	case stockholm = 906057
}

struct WeatherInformation: Decodable {
	let title: String, consolidatedWeather: [Condition]

	struct Condition: Decodable {
		let weatherStateName: String, minTemp: Double, maxTemp: Double
	}
}

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

let baseUrl = "https://www.metaweather.com/api/"

func weatherInfo(for id: Woeid) -> Deferred<Result<WeatherInformation, Error>> {
	baseUrl
		|> networkPathForId(id.rawValue) 	                        //|> logger
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
    dump(result)
}


//: [Next](@next)
