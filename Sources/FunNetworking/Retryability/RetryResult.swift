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
    _ f: @escaping (A) -> Result<B, E>,
    retries: Int,
    coolDown: TimeInterval
) -> (A) -> Result<B, E> {
	retry(f)(coolDown)(retries)
}

public func retry<A, B, E: Error>(
	_ f: @escaping (A) -> Result<B, E>
) -> (TimeInterval) -> (Int) -> (A) -> Result<B, E> {

    func retry(value: A, result: Result<B, E>, currentRun: Int, cooldown: TimeInterval) -> Result<B, E> {
		switch result {
		case .success:
			return result
		case let .failure(error):
            if currentRun > 0 {
                if cooldown > 0 {
                    Thread.sleep(forTimeInterval: cooldown)
                }
                return retry(value: value, result: f(value), currentRun: currentRun - 1, cooldown: cooldown)
            } else {
                return .failure(error)
            }
		}
	}
    return { cooldown in { retries in { value in retry(value: value, result: f(value), currentRun: retries - 1, cooldown: cooldown) } } }
}


