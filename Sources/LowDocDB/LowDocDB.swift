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
    
    public func documentPaths(at folderPath: DocPath) throws -> [DocPath] {
        let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return try urls.map { url in
            let newPath = URL(fileURLWithPath: folderPath.path).appendingPathComponent(url.lastPathComponent).path
            return try DocPath(newPath)
        }
    }
    
    public func documentIsFolder(_ docPath: DocPath) -> Bool {
        let docURL = rootFolder.appendingPathComponent(docPath.path)
        return docURL.hasDirectoryPath
    }
	
	public func enumerator(at folderPath: DocPath) throws -> LowDocDB.Iterator {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let enumerator = fileManager.enumerator(at: docURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
		return Iterator(rootURL: self.rootFolder, dirEnumerator: enumerator)
	}
    
    public func documents(at folderPath: DocPath) throws -> [Data] {
        let docURL = rootFolder.appendingPathComponent(folderPath.path)
		guard docURL.hasDirectoryPath else {
			throw LowDocDBError.pathMustBeADirectory
		}
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let documentsData: [Data] = urls.compactMap { fileManager.contents(atPath: $0.path) }
        return documentsData
    }
    
    public func deleteDocument(at docPath: DocPath) throws {
        let docURL = rootFolder.appendingPathComponent(docPath.path)
        guard docURL != rootFolder else {
            throw LowDocDBError.cantDeleteRoot
        }
        try fileManager.removeItem(at: docURL)
    }
}
public extension LowDocDB {
	class Iterator: IteratorProtocol, Sequence {
		
		private let rootURL: URL
		private let dirEnumerator: FileManager.DirectoryEnumerator?
		
		public init(rootURL: URL, dirEnumerator: FileManager.DirectoryEnumerator?) {
			self.rootURL = rootURL
			self.dirEnumerator = dirEnumerator
		}
		
		public func next() -> DocPath? {
			guard let dirEnumerator = self.dirEnumerator else { return nil }
			if let fileURL = dirEnumerator.nextObject() as? URL, let cleanPath = fileURL.path.components(separatedBy: rootURL.path).last {
				return try? DocPath(cleanPath)
			}
			return nil
		}
	}
}
