import Foundation
import Funswift

public typealias HttpStatusCode = Int

// MARK: - NetworkRequestError
public enum NetworkRequestError: Error {
	case invalidRequest
	case invalidResponse(HttpStatusCode)
	case failed(Error)
}

public func requestSyncR(
	_ request: URLRequest?
) -> IO<Result<Data, Error>> {
	IO(deferred: requestAsyncR(request))
}

// MARK: - asyncRequest
public func requestAsyncR(
	_ request: URLRequest?
) -> Deferred<Result<Data, Error>> {
    requestAsyncE(request).map(Result.init(either:))
}

public func requestSyncE(
	_ request: URLRequest?
) -> IO<Either<Error, Data>> {
	IO(deferred: requestAsyncE(request))
}

public func requestAsyncE(
	_ request: URLRequest?
) -> Deferred<Either<Error, Data>> {
	requestRaw(request: request).mapT { (data, _) in data }
}

public func downloadFile(url: String) -> Deferred<Either<Error, Data>> {

	Deferred { callback in

		guard let url = URL(string: url)
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

		let request = URLRequest(
			url: url,
			cachePolicy: .returnCacheDataElseLoad,
			timeoutInterval: 15
		)

		if let data = URLCache.shared.cachedResponse(for: request)?.data {
			callback(.right(data))
		} else {
			requestRaw(request: request).run { result in
				switch result {
				case let .left(error):
					callback(.left(error))
				case let .right((data, response)):
					let cachedData = CachedURLResponse(response: response, data: data)
					URLCache.shared.storeCachedResponse(cachedData, for: request)
					callback(.right(data))
				}
			}
		}
	}
}

// MARK: - Raw

private func requestRaw(request: URLRequest?) -> Deferred<Either<Error, (Data, URLResponse)>> {

	var urlTask: URLSessionDataTask?

	var deferred = Deferred<Either<Error, (Data, URLResponse)>> { callback in

		guard let request = request
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

		urlTask = URLSession.shared.dataTask(with: request) { data, response, error in

			if let data = data, let response = response as? HTTPURLResponse {
				switch response.statusCode {
				case 200..<300:
					callback(.right((data, response)))
				default:
					callback(.left(NetworkRequestError.invalidResponse(response.statusCode)))
					break
				}
			} else if let error = error {
				callback(.left(NetworkRequestError.failed(error)))
			}
		}
		urlTask?.resume()
	}

	deferred.onCancel = {
		urlTask?.cancel()
	}
	return deferred
}
