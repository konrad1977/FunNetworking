//
//  File.swift
//  
//
//  Created by Mikael Konradsson on 2021-04-27.
//

import Foundation

public func logger<T: Any>(_ value: T) -> T { dump(value); return value }
