//
//  File.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

import struct Foundation.URL
import struct Foundation.Data
import class Foundation.FileManager

public class LowDocDB {
	
	private let rootFolder: URL
	private let fileManager: FileManager = .default
	private let options: LowDocDBOptions
	
	public init(rootFolder: URL, options: LowDocDBOptions = .init()) {
		self.rootFolder = rootFolder
		self.options = options
	}
	
	public func addDocument(at docPath: DocPath, data: Data) throws {
		let depth = URL(fileURLWithPath: docPath.path).pathComponents.dropFirst().dropLast().count
		guard depth <= options.maxDepth else {
			throw LowDocDBError.maxDepthLimitReached
		}
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		let lastFolderURL = docURL.deletingLastPathComponent()
		try fileManager.createDirectory(atPath: lastFolderURL.path, withIntermediateDirectories: true)
		fileManager.createFile(atPath: docURL.path, contents: data)
	}
	
	public func document(at docPath: DocPath) -> Data? {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return fileManager.contents(atPath: docURL.path)
	}
	
	public func documentExist(at docPath: DocPath) -> Bool {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return fileManager.fileExists(atPath: docURL.path)
	}
	
	public func documentPaths(at folderPath: DocPath, includingFolders: Bool) throws -> [DocPath] {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
		if includingFolders {
			return try urls.map { try folderPath.appending($0.lastPathComponent) }
		} else {
			return try urls.compactMap {
				$0.hasDirectoryPath ? nil : try folderPath.appending($0.lastPathComponent)
			}
		}
	}
	
	public func documentIsFolder(_ docPath: DocPath) -> Bool {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return docURL.hasDirectoryPath
	}
	
	public func enumerator(at folderPath: DocPath, includeFolders: Bool) throws -> LowDocDB.Iterator {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let enumerator = fileManager.enumerator(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants], errorHandler: nil)
		return Iterator(rootURL: self.rootFolder, dirEnumerator: enumerator, includeFolders: includeFolders)
	}
	
	public func documents(at folderPath: DocPath) throws -> [Data] {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
		let documentsData: [Data] = urls.compactMap { fileManager.contents(atPath: $0.path) }
		return documentsData
	}
	
	public func deleteDocument(at docPath: DocPath) throws {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		if docURL == rootFolder || docPath.path == "." || docPath.path == "" {
			throw LowDocDBError.cantDeleteRoot
		}
		if docURL.hasDirectoryPath {
			throw LowDocDBError.pathMustBeADocument
		}
		try fileManager.removeItem(at: docURL)
	}
	
	public func deleteItem(at docPath: DocPath) throws {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		if docURL == rootFolder || docPath.path == "." || docPath.path == "" {
			throw LowDocDBError.cantDeleteRoot
		}
		try fileManager.removeItem(at: docURL)
	}
}
