//
//  RetryReader.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation
import Funswift

// MARK: - Retry on Reader
public func retry<A, B>(
	_ f: @escaping (A) -> Reader<A, Result<B, Error>>, retries: Int
) -> (A) -> Reader<A, Result<B, Error>> {
	retry(f)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> Reader<A, Result<B, Error>>
) -> (Int) -> (A) -> Reader<A, Result<B, Error>> {

	func retry(value: A, result: Reader<A, Result<B, Error>>, currentRun: Int) -> Reader<A, Result<B, Error>> {
		switch result.run(value) {
		case .success:
			return result
		case let .failure(error):
			print("error - retrying currentRun: \(currentRun + 1)")
			return currentRun > 0
				? retry(value: value, result: f(value), currentRun: currentRun - 1)
				: Reader { _ in .failure(error) }
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}
