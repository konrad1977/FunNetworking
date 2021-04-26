//
//  DecodeData.swift
//
//
//  Created by Mikael Konradsson on 2021-04-26.
//
import Foundation

public func decodeJsonData<T: Decodable>(
    result: Result<Data, Error>
) -> Result<T, Error> {
	unThrow(try JSONDecoder().decode(T.self, from:result.get()))
}

