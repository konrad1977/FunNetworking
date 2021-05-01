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

    var urlTask: URLSessionDataTask?

    return Deferred { callback in

        guard let request = request
        else { callback(.left(NetworkRequestError.invalidRequest)); return }

        urlTask = URLSession.shared.dataTask(with: request) { data, response, error in

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
        }
        urlTask?.resume()

    } _: {
        urlTask?.cancel()
        print("Cancel")
    }
}

