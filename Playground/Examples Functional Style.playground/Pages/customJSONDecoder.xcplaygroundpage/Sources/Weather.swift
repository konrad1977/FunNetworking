import Foundation

public enum Woeid: Int {
	case copenhagen = 554890
	case london = 44418
	case stockholm = 906057
}

public struct Weather: Decodable {
	public let title: String, consolidatedWeather: [Condition]

	public struct Condition: Decodable {
		public let weatherStateName: String, minTemp, maxTemp: Double
	}
}
