//
//  NetworkResponseValidator.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-05.
//

import Foundation
import Funswift

struct NetworkResponseValidator<T> {
	let validate: (T?, URLResponse?, Error?) -> Either<Error, (T, URLResponse)>
}

extension NetworkResponseValidator {
	static var dataTask: NetworkResponseValidator {
		NetworkResponseValidator { data, response, error in

			if let data = data, let response = response as? HTTPURLResponse {
				switch response.statusCode {
				case 200..<300:
					return .right((data, response))
				default:
					return .left(NetworkRequestError.invalidResponse(response.statusCode))
				}
			} else if let error = error {
				return .left(NetworkRequestError.failed(error))
			}
			return .left(NetworkRequestError.noResponse)
		}
	}

	static var downloadTask: NetworkResponseValidator {
		NetworkResponseValidator.dataTask
	}
}
