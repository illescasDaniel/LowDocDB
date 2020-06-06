//
//  File.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

import struct Foundation.URL

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
		let path = URL(fileURLWithPath: self.path).appendingPathComponent(docPath.path).path
		return try DocPath(path)
	}
	
	public func appending(_ path: String) throws -> DocPath {
		let path = URL(fileURLWithPath: self.path).appendingPathComponent(path).path
		return try DocPath(path)
	}
}
public extension DocPath {
	static var root: DocPath {
		DocPath(rawPath: ".")
	}
}
extension DocPath: CustomStringConvertible {
	public var description: String {
		return path
	}
}
