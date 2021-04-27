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

public func decodeJsonData<T: Decodable>(
    result: Result<Data, Error>
) -> Result<T, Error> {
	unThrow(try JSONDecoder().decode(T.self, from:result.get()))
}

public func decodeJsonData<T: Decodable>(
    result: Either<Error, Data>
) -> Either<Error, T> {

    guard let right = result.right()
    else { return Either<Error, T>.left(DecodingError.invalidData) }

    return unThrow(try JSONDecoder().decode(T.self, from: right))
}

