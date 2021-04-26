//
//  File.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-26.
//

import Foundation

public func unThrow<A>(
	_ f: @autoclosure () throws -> A
) -> Result<A, Error> {
	Result(catching: f)
}
