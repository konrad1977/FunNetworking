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



# Table of content

[Key features](#Key-features)

[Intro](#intro)

[Request types](#Request-types)

- [Asynchrounous Request](#Asynchrounous-Request)
- [Synchrounous Request](#Synchrounous-Request)

[How to do authorization?](#How-to-do-authorization?)

- [Basic](#Example-3.1:-Add-basic-authorization)
- [OAuth](#Example-3.2:-Add-OAuth-authorization)
- [Custom](#Example-3.3:-Custom)

[How to retry a request?](#How-to-retry-a-request?)

- [Debouncing](#Debouncing)

[Cancellation](#Cancellation)

[Operators](#Operators)

## Key features

*FunNetworking is backed by [FunSwift](https://github.com/konrad1977/funswift) a library to do functional programming in Swift. FunNetworking supports different paradigms, you dont have to use operators or write your code in functional style.*

- Run ***multiple*** requests in parallel(*Deferred*) or in sequence(*IO*) and merge the result into one.

  - Synchrounous and Asynchrounous operations can be mixed. But you must decide if the whole operation is in sequence or in parallel.
  - Not all operation have to be network requests, one can be reading from disk, another from SQLite and all can bring data to the final result

- **Chain** operation/requests

  - Chaining operations can easily be done by using `flatMap` or the bind operator `>>-`

- Built in ***retryability***, want to retry that specific request if it fails, thats easy its actually a oneliner. 

  - Retry support with `debounce`:
    - *Linear* (every retry will pause n-seconds until next retry)
    - *Exponential* (every retry will double n-seonds for every retry)

  Retryability has no knowledge about networking at all, it works on the inner structur which can be `Optional<T>`, `Result<T>`, `Deferred<Either>/Deferred<Result>`, `IO<Result>/IO<Either>` and `Reader<Result>`. It can be called either by passing a function directly to retry or a curried version.

- **Power** of mapping the wrapped value inside the result type

  - `mapT` -  map for the inner type.
  - `Deferred` and `IO` has built in support for `mapT`, which means it can map on the wrapped functors data. 
    - Ex `IO<Result<Int, Error>>` can be `mapT(String.init)` which produces `IO<Result<String, Error>>`

- **Cancellation**

  - Built in cancellation. Will raise a `NetworkError.canceledByUser`

- Built in **decoding** of JSON-data. 

  - Built in easy to use jsonDecoding. Need a more speciliced JSONDecoder configuration? Just inject your own. 



## Intro

FunNetworking is an easy to use network wrapper. Its philosophy is to write logicial flow of network code using monads. My personal view is that network code is often widely spread in a project and it can be really hard to follow and debug. Its often like this: the request is made, there is a callback somewhere, there is a retryability handler that steps in somewhere and you are lost when things doesnt work as you expected. FunNetworking tries to solve these problems by keeping the implementation as close as possible to its usage. In FunNetworking to add retry to your request, you just use a [higher order function that](https://en.wikipedia.org/wiki/Higher-order_function) will product a new function that handles the retryability, no callbacks or sprinkling of code all over the codebase.

FunNetworking is of course a pun, it stands for both functional and fun. But dont fear, it fits perfectly in a object oriented enviroment as well.

##### Before you start, you need to import both FunNetworking and Funswift

```swift
import FunNetworking
import Funswift
```

## Request types

FunNetworking supports both synchrounous and asynchronous requests with two different types of result wrapped inside the request type. Its backing types is either `IO` (synchrounous) or `Deferred` (Asynchrounous). 

### Asynchrounous Request

| Signature     | Description                |
| ------------- | -------------------------- |
| requestAsyncR | Deferred<Result<A, Error>> |
| requestAsyncE | Deferred<Either<B, A>>     |

To get the result you need to `run` the monad.

##### Example 1: Asynchronous request - requestAsyncR

```swift
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



### Synchrounous Request

| Signature    | Description          |
| ------------ | -------------------- |
| requestSyncR | IO<Result<A, Error>> |
| requestSyncE | IO<Either<B, A>>     |

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



## How to do chaining?

We can easily do chaining using flatmap or using the bind operator `>>-`. 

##### Example of chaining operations

```swift
let fetchIpNumber: IO<Either<Error, Host>> = {
    "https://api.ipify.org/?format=json"
		|> URL.init(string:)
		>=> requestWithTimeout(30)
		|> requestSyncE
		<&> decodeJsonData
}()

func ipInfoFrom(_ host: Host) -> IO<Either<Error, IpInfo>> {
	"https://ipinfo.io/\(host.ip)/geo"
		|> URL.init(string:)
		>=> requestWithTimeout(30)
		|> retry(requestSyncE, retries: 3, debounce: .linear(2))
		<&> decodeJsonData
}

let fetchHostInfo: (Either<Error, Host>) -> IO<Either<Error, IpInfo>> = { 
  result in
	switch result {
	case let .right(host):
		return ipInfoFrom(host)
	case let .left(error):
		return IO { .left(error) }
	}
}

let ipInfoFetcher = fetchIpNumber >>- fetchHostInfo
ipInfoFetcher.unsafeRun()
```

1. `fetchIpNumber` does a request to fetch the IP-number.

2. `fetchHostInfo` takes the result of the first request and creates a new request.

   -  `fetchIpNumber >>- fetchHostInfo` chains them, but you could use flatMap instead

   - `fetchIpNumber.flatMap(fetchHostInfo)`

## How to do authorization?

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

*Result from 3.1 - httpHeaders: ["Authorization" : "Basic Z3Vlc3Q6Z3Vlc3Q="]*

###### Example 3.2: Add OAuth authorization

```swift
func ageGuessWithOAuth(from name: String) -> IO<Result<Data, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|>	URL.init(string:)
  	>=>	urlRequestWithTimeout(30)
  	|>	authorization(.bearer("secret-token-123"))
  	|>	requestSyncR
}
```

*Result from 3.2: httpHeaders: ["Authorization" : "Bearer secret-token-123"]*

###### Example 3.3: Custom

```swift
func ageGuessWithOAuth(from name: String) -> IO<Result<Data, Error>> {
	"https://api.agify.io/?name=\(name)"
  	|>	URL.init(string:)
  	>=>	urlRequestWithTimeout(30)
  	|>	authorization(.custom(field: "CustomField", data: "5-53455345g"))
  	|>	requestSyncR
}
```

Result from 3.3: httpHeaders: ["Authorization" : "CustomField 5-53455345g"]

## How to retry a request?

To do a retry all you need is to replace: `requestAsyncR` with `retry(requestAsyncR, retries: 3, debounce: .linear(5))`

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



#### Debouncing

Debouncing will sleep the thread a period of time before making the same request again. Linear will add n-seconds of sleep until the next retry while exponential will double it sleep time for every retry.

| Debounce    | Description                             |
| ----------- | --------------------------------------- |
| linear      | Will wait n seconds until next retry    |
| exponential | Will multiply n seconds for every retry |



## Cancellation

You can either call `cancel()` directly on Deferred or add requests to a list of `AnyCancellableDeferred` to cancel all at once. When you're using `Zip` FunNetworking will automatically cancel all requests in the zip.

```swift
import FunNetworking
import Funswift

// Independent requests
let canceable: [AnyCancellableDeferred] = [firstRequest, secondRequest]
canceable.forEach { $0.cancel() }

// zip
zip(firstRequest, secondRequest).cancel()
```



### Operators

Operators might seem hard to understand but they add a lot of flexibility and are easy to learn and master.

| Operators | Name           |                                      Description |
| --------- | -------------- | -----------------------------------------------: |
| \|>       | Pipe           | Inject value into function and return the result |
| >=>       | Fish (compose) |                Compose/injection that might fail |
| <&>       | Map            |      Transform value/type inside a functor/monad |
| >>-       | Bind           |                              Flatmap in disquise |
| <*>       | Applicative    |                    Works like zip but with curry |