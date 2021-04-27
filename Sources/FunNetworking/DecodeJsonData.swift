//
//  DecodeData.swift
//
//
//  Created by Mikael Konradsson on 2021-04-26.
//
import Foundation
import Funswift

enum DecodingError: Error {
    case invalidData
}

// Mark: Private helpers
private func decodeJsonDataResult<T: Decodable>(
	result: Result<Data, Error>,
	decoder: JSONDecoder
) -> Result<T, Error> {
	unThrow(try decoder.decode(T.self, from:result.get()))
}

public func decodeJsonDataEither<T: Decodable>(
	result: Either<Error, Data>,
	decoder: JSONDecoder
) -> Either<Error, T> {

	guard let right = result.right()
	else { return Either<Error, T>.left(DecodingError.invalidData) }

	return unThrow(try decoder.decode(T.self, from: right))
}

// MARK: - Curried version to have a specified decoder
public func decodeJsonData<T: Decodable>(
	with decoder: JSONDecoder
) -> (Result<Data, Error>) -> Result<T, Error> {
	return { result in decodeJsonDataResult(result: result, decoder: decoder) }
}

public func decodeJsonData<T: Decodable>(
	with decoder: JSONDecoder
) -> (Either<Error, Data>) -> Either<Error, T> {
	return { result in decodeJsonDataEither(result: result, decoder: decoder) }
}

// MARK: - Normal version
public func decodeJsonData<T: Decodable>(
    result: Result<Data, Error>
) -> Result<T, Error> {
	decodeJsonDataResult(result: result, decoder: JSONDecoder())
}

public func decodeJsonData<T: Decodable>(
    result: Either<Error, Data>
) -> Either<Error, T> {
	decodeJsonDataEither(result: result, decoder: JSONDecoder())
}

