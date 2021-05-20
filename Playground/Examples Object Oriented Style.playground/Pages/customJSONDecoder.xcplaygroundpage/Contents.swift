import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension String: Error {}

enum Woeid: Int {
    case copenhagen = 554890
    case london = 44418
    case stockholm = 906057
}

struct WeatherInformation: Decodable {
    let title: String, consolidatedWeather: [Condition]

    struct Condition: Decodable {
        let weatherStateName: String, minTemp, maxTemp: Double
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


func weatherUrlFor(id: Int) -> String {
    "https://www.metaweather.com/api/location/\(id)"
}

func weatherInfo(for id: Woeid) -> Deferred<Result<WeatherInformation, Error>> {

    let urlStr = weatherUrlFor(id: id.rawValue)

    guard let url = URL(string: urlStr)
    else { return Deferred { $0(.failure("Failed to create url")) } }

    let requestFunc = retry(requestAsyncR, retries: 3, debounce: .linear(3))
    return requestFunc(URLRequest(url: url))
        .map(decodeJsonData(with: weatherDecoder))
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
