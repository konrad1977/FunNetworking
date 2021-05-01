//
//  Retry.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-07.
//

import Foundation
import Funswift

// MARK: - Retry on Result
public func retry<A, B>(
    _ f: @escaping (A) -> Result<B, Error>,
    retries: Int,
    debounce: Debounce
) -> (A) -> Result<B, Error> {
	retry(f)(debounce)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> Result<B, Error>
) -> (Debounce) -> (Int) -> (A) -> Result<B, Error> {

    func retry(
		value: A,
		result: Result<B, Error>,
		currentRun: Int,
		debounce: Debounce
	) -> Result<B, Error> {

		switch result {
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


