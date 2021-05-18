FunNetworking

!["Logo"](https://github.com/konrad1977/funnetworking/blob/main/Images/logo.png)

![](https://img.shields.io/github/languages/top/konrad1977/funnetworking) ![](https://img.shields.io/github/license/konrad1977/funnetworking)


## Installation

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .package(url: "https://github.com/konrad1977/funnetworking", .branch("main")),
  ]
)
```

## Key features

*FunNetworking is backed by FunSwift which is a library to do functional programming in Swift. FunNetworking supports different styles, you dont have to use operators or write your code in functional style.*

- Run *multiple* requests in parallel and merge the result into one

  - Not all operation have to be network requests, one can be reading from disk, another from SQLite and all can bring data to the final result
  - Synchrounous and Asynchrounous operations can be mixed. But you must decide if the whole operation is in sequence or in parallel.

- Chain operation/requests

  - Chaining operations can easily be done by using `flatMap` or the bind operator `>>-`

- Built in *retryability*, want to retry that specific request if it fails, thats easy its actually a oneliner. 

  - Retry support with `debounce`:
    - *Linear* (every retry will pause n-seconds until next retry)
    - *Exponential* (every retry will double n-seonds for every retry)

  Retryability has no knowledge about networking at all, it works on the inner structur which can be `Optional<T>`, `Result<T>`, `Deferred<Either>/Deferred<Result>`, `IO<Result>/IO<Either>` and `Reader<Result>`. It can be called either by passing a function directly to retry or a curried version.

- Need to change the result of a request?

  - `mapT` -  map for the inner type.
  - `Deferred` and `IO` has built in support for `mapT`, which means it can map on the wrapped functors data. 
    - Ex `IO<Result<Int, Error>>` can be `mapT(String.init)` which produces `IO<Result<String, Error>>`

- Built in decoding of JSON-data. 

  - Built in easy to use jsonDecoding. Need a more speciliced JSONDecoder configuration? Just inject your own. 

## Request types

FunNetworking supports both synchrounous and asynchronous requests with two different types of result wrapped inside the request type. Its backing types is either `IO` (synchrounous) or `Deferred` (Asynchrounous). 

| Asynchrounous requests | Description                |
| ---------------------- | -------------------------- |
| requestAsyncR          | Deferred<Result<A, Error>> |
| requestAsyncE          | Deferred<Either<B, A>>     |

To get the result you need to `run` the monad.

##### Example 1: Asynchronous request - requestAsyncR

```swift
import FunNetworking
import Funswift

func ageGuess(from name: String) -> Deferred<Result<AgeGuess, Error>> {
	"https://api.agify.io/?name=\(name)"
		|>	URL.init(string:)
		>=>	urlRequestWithTimeout(30)
		|>	requestAsyncR
		<&>	decodeJsonData
}

// Get value
ageGuess("Jane").run { result in 
	// handle result
}
```



| Synchrounous requests | Description          |
| --------------------- | -------------------- |
| requestSyncR          | IO<Result<A, Error>> |
| requestSyncE          | IO<Either<B, A>>     |

To get the result you need to call `unsafeRun()` which will be block the current thread until its done.

##### Example 2: Synchronous request - requestSyncR

```swift
func ageGuess(from name: String) -> IO<Result<AgeGuess, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|>	URL.init(string:)
  	>=>	urlRequestWithTimeout(30)
  	|>	requestSyncR
  	<&>	decodeJsonData
}

let result: Result<AgeGuess, Error> = ageGuess().unsafeRun()
// Handle result
```

### How to do authorization?

FunNetworking support three ways of adding authorization (setting the authorization header)

-  Basic Auth - Simple username password. (base64encoded)
-  Bearer Auth. 
- Custom (Supports both custom data and header value fields). If this isn't good enough try using the `setHeader/setHeaders`

###### Example 3.1: Add basic authorization

```swift
func ageGuessWithBasicAuth(from name: String) -> IO<Result<Data, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|>	URL.init(string:)
  	>=>	urlRequestWithTimeout(30)
  	|>	authorization(.basic(username: "guest", password: "guest"))
  	|>	requestSyncR
}
```

###### Example 3.2: Add OAuth authorization

```swift
func ageGuessWithOAuth(from name: String) -> IO<Result<Data, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|>	URL.init(string:)
  	>=>	urlRequestWithTimeout(30)
  	|>	authorization(.bearer("place custom token here"))
  	|>	requestSyncR
}
```

### How to retry a request?

To do a retry all you need is to replace: `requestAsyncR` with (see line 8)

`retry(requestAsyncR, retries: 3, debounce: .linear(5))`

##### Example 4: Asynchronous request with retry - requestAsyncR

```swift
import FunNetworking
import Funswift

func ageGuess(from name: String) -> Deferred<Result<AgeGuess, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|> 	URL.init(string:)
  	>=>	urlRequesstWithTimeout(30)
  	|>	retry(requestAsyncR, retries: 3, debounce: .linear(5))
  	<&>	decodeJsonData
}
```

| Debounce    |                                         |
| ----------- | --------------------------------------- |
| linear      | Will wait n seconds until next retry    |
| exponential | Will multiply n seconds for every retry |



| Operators | Description                     |        Name |
| --------- | ------------------------------- | ----------: |
| \|>       | Inject value into function      |        Pipe |
| >=>       | Compose that might fail         |        Fish |
| <&>       | Change value/type inside a type |         Map |
| >>-       | Flatmap in disquise             |        Bind |
| <*>       | Works like zip but with curry   | Applicative |
