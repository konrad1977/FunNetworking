//
//  DecodeData.swift
//
//
//  Created by Mikael Konradsson on 2021-04-26.
//
import Foundation
import Funswift

// Mark: Private helpers
private func decodeJsonDataResult<T: Decodable>(
	result: Result<Data, Error>,
	decoder: JSONDecoder
) -> Result<T, Error> {
	switch result {
	case let .failure(error):
		return Result<T, Error>.failure(error)
	case let .success(data):
		return unThrow(try decoder.decode(T.self, from: data))
	}
}

public func decodeJsonDataEither<T: Decodable>(
	result: Either<Error, Data>,
	decoder: JSONDecoder
) -> Either<Error, T> {

	switch result {
	case let .left(error):
		return Either<Error, T>.left(error)
	case let .right(data):
		return unThrow(try decoder.decode(T.self, from: data))
	}
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

