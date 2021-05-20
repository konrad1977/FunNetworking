//
//  FunAuthentication.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-13.
//

import Foundation
import Funswift

public enum AuthorizationType {
	case basic(username: String, password: String)
	case bearer(token: String)
	case custom(header: String, data: String)

	var type: String {
		switch self {
		case .basic:
			return "Basic"
		case .bearer:
			return "Bearer"
		case let .custom(header,_):
			return "\(header)"
		}
	}
}

extension AuthorizationType {
	var headerValue: String {
		switch self {
		case let .basic(username, password):
			return "\(username):\(password)"
				.data(using: .utf8)?
				.base64EncodedString() ?? ""
		case let .bearer(token):
			return token
		case let .custom(_, data):
			return data
		}
	}
}

public func authorization(_ authorization: AuthorizationType) -> (URLRequest) -> URLRequest {
	{ $0
		|> setHeader("\(authorization.type) \(authorization.headerValue)", for: "authorization")
	}
}

public let authorizationWith = uncurry(flip(authorization))
