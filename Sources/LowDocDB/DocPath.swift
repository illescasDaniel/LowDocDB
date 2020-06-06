//
//  DocPath.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

import struct Foundation.URL
import class Foundation.NSString

/// Errors thrown by DocPath
public enum DocPathError: Error {
	case invalidPath(path: String)
}

/// Represents relative a document path to a file or folder
public struct DocPath {
	
	/// Relative path to the document
	public let path: String
	
	/// Initializes `DocPath` with a relative `path`.
	///
	/// These kinds of paths are invalid: "../", ".someFile"
	/// - Parameter path: The relative path to the document
	/// - Throws: `DocPathError.invalidPath` if path is invalid
	public init(_ path: String) throws {
		let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmedPath.starts(with: "..") || trimmedPath.hasSuffix("..") || (trimmedPath as NSString).lastPathComponent.starts(with: ".") {
			throw DocPathError.invalidPath(path: trimmedPath)
		}
		self.path = trimmedPath
	}
	
	fileprivate init(rawPath: String) {
		self.path = rawPath
	}
	
	/// New `DocPath` with the appended path.
	/// - Parameter docPath: A path to append to the current one
	/// - Throws: `DocPathError.invalidPath` if new path is invalid
	/// - Returns: The current path with the new one appended
	public func appending(_ docPath: DocPath) throws -> DocPath {
		let newPath = (self.path as NSString).appendingPathComponent(docPath.path)
		return try DocPath(newPath)
	}
	
	/// New `DocPath` with the appended path.
	/// - Parameter docPath: A path string to append to the current document path
	/// - Throws: `DocPathError.invalidPath` if new path is invalid
	/// - Returns: The current path with the new one appended
	public func appending(_ somePath: String) throws -> DocPath {
		let newPath = (self.path as NSString).appendingPathComponent(try DocPath(somePath).path)
		return try DocPath(newPath)
	}
}
public extension DocPath {
	/// The root path the database
	///
	/// You can use this path to append others too:
	/// ```
	/// DocPath.root.appending("myDocs/doc1.txt")
	/// ```
	static var root: DocPath {
		DocPath(rawPath: "")
	}
}
extension DocPath: CustomStringConvertible {
	/// Returns the relative path description
	public var description: String {
		return path
	}
}
