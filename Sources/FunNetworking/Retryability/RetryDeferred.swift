//
//  RetryDeferred.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation
import Funswift


// MARK: - Retry on Deferred<Either<E, B>>
public func retry<A, B, E>(
	_ f: @escaping (A) -> Deferred<Either<E, B>>,
	retries: Int,
	debounce: Debounce
) -> (A) -> Deferred<Either<E, B>> {
	retry(f)(debounce)(retries)
}

public func retry<A, B, E>(
	_ f: @escaping (A) -> Deferred<Either<E, B>>
) -> (Debounce) -> (Int) -> (A) -> Deferred<Either<E, B>> {

	let dispatchGroup = DispatchGroup()

	func retry(
		value: A,
		result: Deferred<Either<E, B>>,
		currentRun: Int,
		debounce: Debounce
	) -> Deferred<Either<E, B>> {

		dispatchGroup.enter()

		var success = false
		result.run { result in
			switch result {
			case .right:
				success = true
			case .left:
				success = false
			}
			dispatchGroup.leave()
		}

		dispatchGroup.wait()

		if success == false && currentRun > 0 {
			Thread.sleep(forTimeInterval: debounce.value)
			return retry(value: value, result: f(value), currentRun: currentRun - 1, debounce: debounce)
		}
		return result
	}
	
	return {
		debounce in {
			retries in { value in
				retry(value: value, result: f(value), currentRun: retries, debounce: debounce)
			}
		}
	}
}

// MARK: - Retry on Deferred<Result>
public func retry<A, B>(
	_ f: @escaping (A) -> Deferred<Result<B, Error>>,
	retries: Int,
	debounce: Debounce
) -> (A) -> Deferred<Result<B, Error>> {
	retry(f)(debounce)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> Deferred<Result<B, Error>>
) -> (Debounce) -> (Int) -> (A) -> Deferred<Result<B, Error>> {

	let dispatchGroup = DispatchGroup()

	func retry(
		value: A,
		result: Deferred<Result<B, Error>>,
		currentRun: Int,
		debounce: Debounce
	) -> Deferred<Result<B, Error>> {

		dispatchGroup.enter()

		var success = false
		result.run { result in
			switch result {
			case .success:
				success = true
			case .failure:
				success = false
			}
			dispatchGroup.leave()
		}
		dispatchGroup.wait()

		if success == false && currentRun != 0 {
			Thread.sleep(forTimeInterval: debounce.value)
			return retry(value: value, result: f(value), currentRun: currentRun - 1, debounce: debounce)
		}
		return result
	}

	return {
		debounce in {
			retries in { value in
				retry(value: value, result: f(value), currentRun: retries, debounce: debounce)
			}
		}
	}
}

