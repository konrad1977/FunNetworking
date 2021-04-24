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
		case let .success(value):
			return .success(value)
		case let .failure(error):
			return currentRun > 0
				? retry(value: value, result: f(value), currentRun: currentRun - 1)
				: .failure(error)
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}

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

// MARK: - Retry on Optionals
public func retry<A, B>(
	_ f: @escaping (A) -> B?
) -> (Int) -> (A) -> B? {

	func retry(value: A, result: B?, currentRun: Int) -> B? {
		switch result {
		case .none:
			return currentRun > 0
				? retry(value: value, result: f(value), currentRun: currentRun - 1)
				: .none
		case .some(let value):
			return .some(value)
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}

// MARK: - Retry on Deferred
public func retry<A, B>(
	_ f: @escaping (A) -> Deferred<Result<B, Error>>, retries: Int
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
