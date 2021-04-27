//
//  RetryOptional.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation

// MARK: - Retry on Optionals
public func retry<A, B>(
	_ f: @escaping (A) -> B?, retries: Int
) -> (A) -> B? {
	retry(f)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> B?
) -> (Int) -> (A) -> B? {

	func retry(value: A, result: B?, currentRun: Int) -> B? {
		switch result {
		case .some:
			return result
		case .none:
			return currentRun > 0
				? retry(value: value, result: f(value), currentRun: currentRun - 1)
				: .none
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}
