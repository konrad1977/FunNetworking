//
//  File.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-01.
//

import Foundation

public enum Debounce {
	case linear(TimeInterval)
	case exponential(TimeInterval)
}

extension Debounce {

    public var value: TimeInterval {
		switch self {
		case let .linear(value):
			return value
		case let .exponential(value):
			return value
		}
	}

    public func run() -> Self {
        switch self {
        case .exponential,
             .exponential(value):
            return .exponential(value + value)
        case .linear,
             .linear(value):
            return .linear(value)
        }
    }
}
