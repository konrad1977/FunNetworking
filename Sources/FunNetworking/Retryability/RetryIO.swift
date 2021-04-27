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
	retries: Int
) -> (A) -> IO<Result<B, Error>> {
	retry(f)(retries)
}

public func retry<A, B>(
	_ f: @escaping (A) -> IO<Result<B, Error>>
) -> (Int) -> (A) -> IO<Result<B, Error>> {

	func retry(value: A, result: IO<Result<B, Error>>, currentRun: Int) -> IO<Result<B, Error>> {
		switch result.unsafeRun() {
		case .success:
			return result
		case .failure:
			return currentRun > 0
				? retry(value: value, result: result, currentRun: currentRun - 1)
				: result
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}

// MARK: - IO<Result>
public func retry<A, B, E>(
	_ f: @escaping (A) -> IO<Either<E, B>>,
	retries: Int
) -> (A) -> IO<Either<E, B>> {
	retry(f)(retries)
}

public func retry<A, B, E>(
	_ f: @escaping (A) -> IO<Either<E, B>>
) -> (Int) -> (A) -> IO<Either<E, B>> {

	func retry(value: A, result: IO<Either<E, B>>, currentRun: Int) -> IO<Either<E, B>> {
		switch result.unsafeRun() {
		case .right:
			return result
		case .left:
			return currentRun > 0
				? retry(value: value, result: result, currentRun: currentRun - 1)
				: result
		}
	}
	return { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1) } }
}
