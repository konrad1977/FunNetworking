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
	retries: Int
) -> (A) -> Deferred<Either<E, B>> {
	retry(f)(retries)
}

public func retry<A, B, E>(
	_ f: @escaping (A) -> Deferred<Either<E, B>>
) -> (Int) -> (A) -> Deferred<Either<E, B>> {

	let dispatchGroup = DispatchGroup()

	func retry(value: A, result: Deferred<Either<E, B>>, currentRun: Int) -> Deferred<Either<E, B>> {

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
			return retry(value: value, result: f(value), currentRun: currentRun - 1)
		} else {
			return result
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}

// MARK: - Retry on Deferred<Result>
public func retry<A, B>(
	_ f: @escaping (A) -> Deferred<Result<B, Error>>,
	retries: Int
) -> (A) -> Deferred<Result<B, Error>> {
	retry(f)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> Deferred<Result<B, Error>>
) -> (Int) -> (A) -> Deferred<Result<B, Error>> {

	let dispatchGroup = DispatchGroup()

	func retry(value: A, result: Deferred<Result<B, Error>>, currentRun: Int) -> Deferred<Result<B, Error>> {

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

		if success == false && currentRun > 0 {
			print("error - retrying currentRun: \(currentRun + 1)")
			return retry(value: value, result: f(value), currentRun: currentRun - 1)
		} else {
			return result
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}

