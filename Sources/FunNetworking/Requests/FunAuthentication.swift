//
//  FunAuthentication.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-13.
//

import Foundation
import Funswift

public func login(username: String, password: String) -> (URLRequest) -> URLRequest {
	return { request in

		guard let base64EncodedPhrase = "\(username):\(password)"
			.data(using: .utf8)?
			.base64EncodedString()
		else { return request }
		
		return request
			|> setHeader("Basic \(base64EncodedPhrase)", for: "authorization")
	}
}
