import Foundation
import FunNetworking
import Funswift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension String: Error {}

let stringWithEncoding = flip(curry(String.init(data:encoding:)))
let utf8String = stringWithEncoding(.utf8)

func createRequest() -> URLRequest? {
    URL(string: "https://jigsaw.w3.org/HTTP/Basic/")
        .flatMap {
            URLRequest(url: $0, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        }
}


func login(request: URLRequest?) -> Deferred<Result<Data, Error>> {
    guard let request = request
    else { return Deferred { $0(.failure("Invalid request")) } }

    return requestAsyncR(
        authorizationWith(
            request,
            .basic(username: "guest", password: "guest")
        )
    )
}

login(request: createRequest())
    .mapT(utf8String)
    .run { result in
        dump(result)
    }
