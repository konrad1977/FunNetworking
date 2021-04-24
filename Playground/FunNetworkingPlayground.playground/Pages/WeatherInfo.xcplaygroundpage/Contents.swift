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

	let title: String
	let consolidatedWeather: [Condition]

	struct Condition: Decodable {
		let weatherStateName: String
		let minTemp: Double
		let maxTemp: Double
	}
}

func decodeData(
	result: Result<Data, Error>
) -> Result<WeatherInformation, Error> {
	Result(
		catching: {
			try WeatherJsonDecoder.decode(WeatherInformation.self, from:result.get())
		}
	)
}

let weatherLocationForWoeId: (Int) -> (String) -> String = {
	id in { base in base + "location/\(id)" }
}

let WeatherJsonDecoder: JSONDecoder = {
	let jsonDecoder = JSONDecoder()
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd"
	jsonDecoder.dateDecodingStrategy = .formatted(formatter)
	jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	return jsonDecoder
}()

func logStep<T: Any>(_ value: T) -> T { dump(value); return value }

let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))
let urlRequesstWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))

func weatherInfo(for id: Woeid) -> Deferred<Result<WeatherInformation, Error>> {
	"https://www.metaweather.com/api/"
		|> weatherLocationForWoeId(id.rawValue)
		|> URL.init(string:)
		>=> urlRequesstWithTimeout(30)
		//|> retry(asyncRequest, retries: 3)
		|> asyncRequest
		>>> map(decodeData)
}

weatherInfo(for: .stockholm)
	.run { print($0) }

//: [Next](@next)
