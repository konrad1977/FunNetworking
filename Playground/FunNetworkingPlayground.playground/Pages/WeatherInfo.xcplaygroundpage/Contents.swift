//: [Previous](@previous)

import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

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

let WeatherJsonDecoder: JSONDecoder = {
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

func logStep<T: Any>(_ value: T) -> T { dump(value); return value }

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

let baseUrl = "https://www.metaweather.com/api/"

func weatherInfo(for id: Woeid) -> Deferred<Result<WeatherInformation, Error>> {
	baseUrl
		|> networkPathForId(id.rawValue) 	|> logStep
		|> URL.init(string:) 				|> logStep
		>=> urlRequesstWithTimeout(30) 		|> logStep
		|> retry(asyncRequest)(3)			|> logStep
		<&> decodeData
}

zip(
	weatherInfo(for: .stockholm),
	weatherInfo(for: .london),
	weatherInfo(for: .copenhagen)
).map(zip)
.run { result in
	print(result)
}


//: [Next](@next)
