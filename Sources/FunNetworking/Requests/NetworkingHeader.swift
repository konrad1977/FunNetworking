//
//  NetworkingHeader.swift
//
//
//  Created by Mikael Konradsson on 2021-05-05.
//

import Foundation
import Funswift

public func validHttpHeaders(for request: URLRequest) -> [String: String] {
	request.allHTTPHeaderFields ?? [:]
}

public func setHeader(_ value: String, for field: String) -> (URLRequest) -> URLRequest {
	return { request in
		var reqCpy = request
		reqCpy.allHTTPHeaderFields = (validHttpHeaders(for: request) <> [value: field])
		return reqCpy
	}
}

public func setHeaders(_ incomingHeaders: [String: String]) -> (URLRequest) -> URLRequest {
	return { request in
		var reqCpy = request
		reqCpy.allHTTPHeaderFields = (validHttpHeaders(for: request) <> incomingHeaders)
		return reqCpy
	}
}
