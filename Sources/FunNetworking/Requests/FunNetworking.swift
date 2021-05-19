import Foundation
import Funswift

public typealias HttpStatusCode = Int

public let requestWithCachePolicy = flip(curry(URLRequest.init(url:cachePolicy:timeoutInterval:)))

// MARK: - NetworkRequestError
public enum NetworkRequestError: Error {
	case invalidRequest
	case invalidResponse(HttpStatusCode)
	case failed(Error)
	case noResponse
    case canceledByUser
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
	deferredDataTask(request: request).mapT { (data, _) in data }
}

// MARK: - dataTask
public func deferredDataTask(request: URLRequest?) -> Deferred<Either<Error, (Data, URLResponse)>> {

	var urlTask: URLSessionDataTask?
    var canceled = false

	var deferred = Deferred<Either<Error, (Data, URLResponse)>> { callback in

		guard let request = request
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

		urlTask = URLSession.shared.dataTask(with: request) { data, response, error in
            canceled
                ? callback(.left(NetworkRequestError.canceledByUser))
                : callback(NetworkResponseValidator.dataTask.validate(data, response, error))
		}
		urlTask?.resume()
	}

    deferred.onCancel = {
        canceled = true
        urlTask?.cancel()
    }
	return deferred
}

// MARK: - dataTask
public func deferredDownloadTask(request: URLRequest?) -> Deferred<Either<Error, (URL, URLResponse)>> {

	var urlTask: URLSessionDownloadTask?
    var canceled = false

	var deferred = Deferred<Either<Error, (URL, URLResponse)>> { callback in

		guard let request = request
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

		urlTask = URLSession.shared.downloadTask(with: request) { data, response, error in
            canceled
                ? callback(.left(NetworkRequestError.canceledByUser))
                : callback(NetworkResponseValidator.dataTask.validate(data, response, error))
		}
		urlTask?.resume()
	}

    deferred.onCancel = {
        canceled = true
        urlTask?.cancel()
    }
	return deferred
}
