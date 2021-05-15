//
//  File.swift
//  
//
//  Created by Mikael Konradsson on 2021-05-15.
//

#if os(macOS)
import AppKit.NSImage
public typealias ImageType = NSImage
#else
import UIKit.UIImage
public typealias ImageType = UIImage
#endif

public typealias FunImage = ImageType
