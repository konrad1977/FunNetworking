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
	var value: TimeInterval {
		switch self {
		case let .linear(value):
			return value
		case let .exponential(value):
			return value
		}
	}
}
