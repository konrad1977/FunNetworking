//
//  POST.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-27.
//

import Foundation
import Funswift

public func post(_ data: Data) -> (URLRequest) -> URLRequest {
	return { request in
		var cpy = request
		cpy.httpMethod = "POST"
		cpy.httpBody = data
		return cpy
	}
}

public func post(_ dictionary: [String: Any]) -> (URLRequest) -> URLRequest {
	return { request in
		var cpy = request
		cpy.httpMethod = "POST"
		cpy.httpBody = try? JSONSerialization.data(withJSONObject: dictionary)
		return cpy
			|> setHeader("application/json", for: "Content-Type")
			<> setHeader("application/json", for: "Accept")
	}
}
