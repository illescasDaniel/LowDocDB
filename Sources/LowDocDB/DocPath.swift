//
//  File.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

import struct Foundation.URL
import class Foundation.NSString

public enum DocPathError: Error {
	case invalidPath(path: String)
}
public struct DocPath {
	
	public let path: String
	
	public init(_ path: String) throws {
		let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmedPath.starts(with: "..") || trimmedPath.hasSuffix("..") || URL(fileURLWithPath: trimmedPath).lastPathComponent.starts(with: ".") {
			throw DocPathError.invalidPath(path: trimmedPath)
		}
		self.path = trimmedPath
	}
	
	fileprivate init(rawPath: String) {
		self.path = rawPath
	}
	
	public func appending(_ docPath: DocPath) throws -> DocPath {
		let newPath = (self.path as NSString).appendingPathComponent(docPath.path)
		return try DocPath(newPath)
	}
	
	public func appending(_ somePath: String) throws -> DocPath {
		let newPath = (self.path as NSString).appendingPathComponent(somePath)
		return try DocPath(newPath)
	}
}
public extension DocPath {
	static var root: DocPath {
		DocPath(rawPath: "")
	}
}
extension DocPath: CustomStringConvertible {
	public var description: String {
		return path
	}
}
