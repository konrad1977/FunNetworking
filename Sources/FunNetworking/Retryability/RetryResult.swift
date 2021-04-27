//
//  Retry.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-07.
//

import Foundation
import Funswift

// MARK: - Retry on Result
public func retry<A, B, E: Error>(
	_ f: @escaping (A) -> Result<B, E>, retries: Int
) -> (A) -> Result<B, E> {
	retry(f)(retries)
}

public func retry<A, B, E: Error>(
	_ f: @escaping (A) -> Result<B, E>
) -> (Int) -> (A) -> Result<B, E> {

	func retry(value: A, result: Result<B, E>, currentRun: Int) -> Result<B, E> {
		switch result {
		case .success:
			return result
		case let .failure(error):
			return currentRun > 0
				? retry(value: value, result: f(value), currentRun: currentRun - 1)
				: .failure(error)
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}


