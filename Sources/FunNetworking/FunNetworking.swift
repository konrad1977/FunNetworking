import Foundation
import Funswift

public typealias HttpStatusCode = Int

// MARK: - NetworkRequestError
public enum NetworkRequestError: Error {
	case invalidRequest
	case invalidResponse(HttpStatusCode)
	case failed(Error)
}

public func syncRequest(
	_ request: URLRequest?
) -> IO<Result<Data, Error>> {
	IO(deferred: asyncRequest(request))
}

// MARK: - asyncRequest
public func asyncRequest(
	_ request: URLRequest?
) -> Deferred<Result<Data, Error>> {

	let result: Deferred<Either<Error, Data>> = asyncRequest(request)
	return result.map { either -> Result<Data, Error> in
		switch either {
		case let .left(error):
			return .failure(error)
		case let .right(data):
			return .success(data)
		}
	}
}

// MARK: - asyncRequest
public func syncRequest(
	_ request: URLRequest?
) -> IO<Either<Error, Data>> {
	IO(deferred: asyncRequest(request))
}

public func asyncRequest(
	_ request: URLRequest?
) -> Deferred<Either<Error, Data>> {

	return Deferred { callback in

		guard let request = request
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

		URLSession.shared.dataTask(with: request) { data, response, error in

			if let data = data, let response = response as? HTTPURLResponse {
				switch response.statusCode {
				case 200..<300:
					callback(.right(data))
				default:
					callback(.left(NetworkRequestError.invalidResponse(response.statusCode)))
					break
				}
			} else if let error = error {
				callback(.left(NetworkRequestError.failed(error)))
			}
		}.resume()
	}
}
