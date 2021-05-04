import Funswift
import Foundation
import UIKit

public enum DownloadFilerError: Error {
	case invalidImageData
}

private func createRequest(url: String) -> Either<Error, URLRequest> {
	guard let url = URL(string: url)
	else { return .left(NetworkRequestError.invalidRequest) }

	let requestWithTimeout = flip(requestWithCachePolicy(.returnCacheDataElseLoad))
	return .right(url |> requestWithTimeout(15))
}

// MARK: - Download Either Request
public func downloadFile(request: URLRequest?) -> Deferred<Either<Error, Data>> {

	Deferred { callback in

		guard let request = request
		else { callback(.left(NetworkRequestError.invalidRequest)); return }

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

public func downloadFile(url: String) -> Deferred<Either<Error, Data>> {
	switch createRequest(url: url) {
	case let .left(error):
		return Deferred { $0(.left(error)) }
	case let .right(request):
		return downloadFile(request:request)
	}
}

// MARK: - Download Result Request
public func downloadFile(request: URLRequest?) -> Deferred<Result<Data, Error>> {
	downloadFile(request: request)
		.map(Result.init(either:))
}

public func downloadFile(url: String) -> Deferred<Result<Data, Error>> {
	downloadFile(url: url)
		.map(Result.init(either:))
}

// MARK: - Download image with Request
public func downloadImage(request: URLRequest?) -> Deferred<Result<UIImage?, Error>> {
	downloadFile(request: request)
		.map(Result.init(either:))
		.mapT(UIImage.init(data:))
}

public func downloadImage(request: URLRequest?) -> Deferred<Either<Error, UIImage?>> {
	downloadFile(request: request)
		.mapT(UIImage.init(data:))
}

// MARK: - Download image from raw string
public func downloadImage(url: String) -> Deferred<Either<Error, UIImage?>> {
	switch createRequest(url: url) {
	case let .left(error):
		return Deferred { $0(.left(error)) }
	case let .right(request):
		return downloadImage(request:request)
	}
}

public func downloadImage(url: String) -> Deferred<Result<UIImage?, Error>> {
	downloadImage(url: url)
		.map(Result.init(either:))
}


