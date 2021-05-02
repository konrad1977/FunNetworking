# FunNetworking
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
FunNetworking is a lightweight wrapper around several monads found in [Funswift](https://github.com/konrad1977/funswift). It supports Chaining, Zipping, requests no matter if they are synchrounous or asynchrounous. 

- Zip and run multiple request at once and merge the result into one (if you want to)
  
- Zipping request can be mixed in with reading from disk or any other operation. It doesnt have to a network request.
  - Async zip can be mixed with Sync operations and vice versa. 
  
- Chain operation using `>>-` operator or `flatMap`. Need the result from an earlier request to make a new request? Thats easy, just flatMap on the first request and fire up a second request.

- Built in retryability. All request function can be passed into a retry that will wrap the function and run it x times

  - Retry support `debounce`:
    - Linear (every retry will pause n-seconds until next retry)
    - Exponential (every retry will double n-seonds for every retry)

  Retryability has no knowledge about networking at all, it works on the inner structur which can be Optional<T>, Result<T>, Deferred<Either>/Deferred<Result>, IO<Result>/IO<Either> and Reader<Result>. It can be called either by passing a function directly to retry or a curried version.

- mapT - support for some wrapped functors/monads
  - `Deferred` and `IO` has built in support for `mapT`, which means it can map on the wrapped functors data. 
    - Ex `IO<Result<Int, Error>>` can be `mapT(String.init)` which produces `IO<Result<String, Error>>`
- DecodeJsonData
  - Built in easy to use jsonDecoding. Supports curried version for injecting specialized JSONDecoder.