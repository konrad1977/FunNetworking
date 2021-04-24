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

## Usage
FunNetworking is a wrapper around URLSession that lets you wrapp the result of callback around a Future (Deferred). It has support Retries, but not yet cooldowns/back off feature.