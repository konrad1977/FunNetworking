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
	_ f: @escaping (A) -> Reader<A, Result<B, Error>>,
	retries: Int,
	debounce: Debounce
) -> (A) -> Reader<A, Result<B, Error>> {
	retry(f)(debounce)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> Reader<A, Result<B, Error>>
) -> (Debounce) -> (Int) -> (A) -> Reader<A, Result<B, Error>> {

	func retry(
		value: A,
		result: Reader<A, Result<B, Error>>,
		currentRun: Int,
		debounce: Debounce
	) -> Reader<A, Result<B, Error>> {

		switch result.run(value) {
		case .success:
			return result
		case .failure:
			if currentRun > 0 {
				Thread.sleep(forTimeInterval: debounce.value)
				return retry(value: value, result: f(value), currentRun: currentRun - 1, debounce: debounce)
			}
			return result
		}
	}
	return {
		debounce in {
			retries in { value in
				retry(value: value, result: f(value), currentRun: retries, debounce: debounce)
			}
		}
	}
}
