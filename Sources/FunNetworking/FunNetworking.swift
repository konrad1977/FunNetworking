import Foundation
import Funswift

public typealias HttpStatusCode = Int

// MARK: - NetworkRequestError
public enum NetworkRequestError: Error {
	case invalidRequest
	case invalidResponse(HttpStatusCode)
	case failed(Error)
}

// MARK: - asyncRequest
public func asyncRequest(
	_ request: URLRequest?
) -> Deferred<Result<Data, Error>> {

	return Deferred { callback in

		guard let request = request
		else { callback(.failure(NetworkRequestError.invalidRequest)); return }

		URLSession.shared.dataTask(with: request) { data, response, error in

			if let data = data, let response = response as? HTTPURLResponse {
				switch response.statusCode {
				case 200..<300:
					callback(.success(data))
				default:
					callback(.failure(NetworkRequestError.invalidResponse(response.statusCode)))
					break
				}
			} else if let error = error {
				callback(.failure(NetworkRequestError.failed(error)))
			}
		}.resume()
	}
}
