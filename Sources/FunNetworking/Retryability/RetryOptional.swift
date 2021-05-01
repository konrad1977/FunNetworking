//
//  RetryOptional.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation

// MARK: - Retry on Optionals
public func retry<A, B>(
	_ f: @escaping (A) -> B?,
	retries: Int,
	debounce: Debounce
) -> (A) -> B? {
	retry(f)(debounce)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> B?
) -> (Debounce) -> (Int) -> (A) -> B? {

	func retry(
		value: A,
		result: B?,
		currentRun: Int,
		debounce: Debounce
	) -> B? {
		
		switch result {
		case .some:
			return result
		case .none:
			if currentRun > 0 {
				Thread.sleep(forTimeInterval: debounce.value)
                return retry(value: value, result: f(value), currentRun: currentRun - 1, debounce: debounce.run())
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
