//
//  RetryIO.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation
import Funswift

// MARK: - IO<Result>
public func retry<A, B>(
	_ f: @escaping (A) -> IO<Result<B, Error>>,
	retries: Int,
	debounce: Debounce
) -> (A) -> IO<Result<B, Error>> {
	retry(f)(debounce)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> IO<Result<B, Error>>
) -> (Debounce) -> (Int) -> (A) -> IO<Result<B, Error>> {

	func retry(
		value: A,
		result: IO<Result<B, Error>>,
		currentRun: Int,
		debounce: Debounce
	) -> IO<Result<B, Error>> {

		switch result.unsafeRun() {
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

// MARK: - IO<Result>
public func retry<A, B, E>(
	_ f: @escaping (A) -> IO<Either<E, B>>,
	retries: Int,
	debounce: Debounce
) -> (A) -> IO<Either<E, B>> {
	retry(f)(debounce)(retries)
}

public func retry<A, B, E>(
	_ f: @escaping (A) -> IO<Either<E, B>>
) -> (Debounce) -> (Int) -> (A) -> IO<Either<E, B>> {

	func retry(
		value: A,
		result: IO<Either<E, B>>,
		currentRun: Int,
		debounce: Debounce
	) -> IO<Either<E, B>> {

		switch result.unsafeRun() {
		case .right:
			return result
		case .left:
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
