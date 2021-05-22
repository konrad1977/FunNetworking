import Foundation

public struct IpInfo: Decodable {
	public let ip, city, region, country, loc, postal: String
}
