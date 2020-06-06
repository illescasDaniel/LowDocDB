//
//  File.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

public struct LowDocDBOptions {
	
	public let maxDepth: UInt8
	
	public init(maxDepth: UInt8 = .max) {
		self.maxDepth = maxDepth
	}
}

public enum LowDocDBError: Error {
	case maxDepthLimitReached
	case cantDeleteRoot
	case pathMustBeADirectory
	case pathMustBeADocument
}
