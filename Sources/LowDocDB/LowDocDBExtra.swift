//
//  LowDocDBExtra.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

/// Database options
public struct LowDocDBOptions {
	
	/// Max folder depth
	public let maxDepth: UInt8
	
	public init(maxDepth: UInt8 = .max) {
		self.maxDepth = maxDepth
	}
}

/// Database errors
public enum LowDocDBError: Error {
	case maxDepthLimitReached
	case cantDeleteRoot
	case pathMustBeADirectory
	case pathMustBeADocument
	case folderDoesNotExist
}
