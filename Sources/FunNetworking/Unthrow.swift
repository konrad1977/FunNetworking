//
//  File.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-26.
//

import Foundation
import Funswift

public func unThrow<A>(
	_ f: @autoclosure () throws -> A
) -> Result<A, Error> {
	Result(catching: f)
}


public func unThrow<A>(
    _ f: @autoclosure () throws -> A
) -> Either<Error, A> {

    do {
        let result: A = try f()
        return .right(result)
    } catch {
        return .left(error)
    }
}
