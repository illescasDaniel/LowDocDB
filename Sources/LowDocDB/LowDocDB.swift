//
//  LowDocDB.swift
//
//
//  Created by Daniel Illescas Romero on 05/06/2020.
//

import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.ObjCBool
import class Foundation.NSString
import class Foundation.FileManager

/// Low level database
public class LowDocDB {
	
	private let rootFolder: URL
	private let fileManager: FileManager = .default
	private let options: LowDocDBOptions
	
	/// Initializes the database with a root folder and some options.
	/// - Parameters:
	///   - rootFolder: The physical hard drive folder path that will be the root of the database. If this is not a folder a `fatalError` will be thrown.
	///   - options: Database options, like max folders depth
	public init(rootFolder: URL, options: LowDocDBOptions = .init()) {
		
		switch FileManager.default.isDirectory(url: rootFolder) {
		case .fileDoesNotExist:
			do {
				try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true, attributes: nil)
			} catch {
				fatalError("Database root folder doesn't exist and it couldn't be created because: \(error.localizedDescription)")
			}
		case .isDirectory:
			break
		case .isNotDirectory:
			fatalError("Database root path must be a folder")
		}
		
		self.rootFolder = rootFolder
		self.options = options
	}
	
	/// Adds a document to the database.
	///
	/// Overrides any existing file.
	/// - Parameters:
	///   - docPath: Relative path of the new document
	///   - data: Document data
	/// - Throws: `LowDocDBError.maxDepthLimitReached` if max depth is reached, other error if fails to create the intermediate folders
	public func addDocument(at docPath: DocPath, data: Data) throws {
		let depth = (docPath.path as NSString).pathComponents.dropLast().count
		guard depth <= options.maxDepth else {
			throw LowDocDBError.maxDepthLimitReached
		}
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		let lastFolderURL = docURL.deletingLastPathComponent()
		try fileManager.createDirectory(atPath: lastFolderURL.path, withIntermediateDirectories: true)
		fileManager.createFile(atPath: docURL.path, contents: data)
	}
	
	/// Retrieves a document and returns its data representation
	/// - Parameter docPath: Relative path of the document
	/// - Returns: A `Data` object if document was found and is valid, `nil` otherwise (file doesn't exist, is a folder, etc)
	public func document(at docPath: DocPath) -> Data? {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return fileManager.contents(atPath: docURL.path)
	}
	
	/// If a document (either folder or file) exists
	/// - Parameter docPath: Relative path of the document
	/// - Returns: `true` if file exists, `false` otherwise
	public func documentExist(at docPath: DocPath) -> Bool {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return fileManager.fileExists(atPath: docURL.path)
	}
	
	/// All document paths, including folder or not, from the given `folderPath`.
	/// - Parameters:
	///   - folderPath: Relative folder path.
	///   - includingFolders: Wether to include folders or not when returning the paths.
	/// - Throws: `LowDocDBError.pathMustBeADirectory` if path is not a directory, other errors might be thrown due to invalid paths
	/// - Returns: Document paths of files within the given folder
	public func documentPaths(at folderPath: DocPath, includingFolders: Bool) throws -> [DocPath] {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		
		switch FileManager.default.isDirectory(url: docURL) {
		case .fileDoesNotExist:
			return []
		case .isDirectory:
			break
		case .isNotDirectory:
			throw LowDocDBError.pathMustBeADirectory
		}
		
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
		if includingFolders {
			return try urls.map { try folderPath.appending($0.lastPathComponent) }
		} else {
			return try urls.compactMap {
				fileManager.isDirectory(url: $0) == .isDirectory ? nil : try folderPath.appending($0.lastPathComponent)
			}
		}
	}
	
	/// If a document exists and is a folder.
	/// - Parameter docPath: A relative document path.
	/// - Returns: true if the document exists and is a folder, false otherwise.
	public func documentIsFolder(_ docPath: DocPath) -> Bool {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		return FileManager.default.isDirectory(url: docURL) == .isDirectory
	}
	
	/// Iterator that can enumerate all files within a given folder.
	/// - Parameters:
	///   - folderPath: A relative folder path.
	///   - includeFolders: Whether include folders or not while enumerating files.
	/// - Throws:
	/// `LowDocDBError.folderDoesNotExist` if folder does't exit.
	/// `LowDocDBError.pathMustBeADirectory` if path is not a valid directory.
	/// - Returns: An iterator which values are of `DocPath` type
	public func enumerator(at folderPath: DocPath, includeFolders: Bool) throws -> LowDocDB.Iterator {
		
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		
		switch FileManager.default.isDirectory(url: docURL) {
		case .fileDoesNotExist:
			throw LowDocDBError.folderDoesNotExist
		case .isDirectory:
			break
		case .isNotDirectory:
			throw LowDocDBError.pathMustBeADirectory
		}
		
		let enumerator = fileManager.enumerator(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants], errorHandler: nil)
		return Iterator(rootURL: self.rootFolder, dirEnumerator: enumerator, includeFolders: includeFolders)
	}
	
	/// An array containing all data from files of the given folder.
	///
	///  It  skips folders.
	/// - Parameter folderPath: A relative folder path to extract document data from its files.
	/// - Throws: `LowDocDBError.pathMustBeADirectory` if folder path is not a directory.
	/// - Returns: An array containing all files in `folderPath` as `Data` objects.
	public func documents(at folderPath: DocPath) throws -> [Data] {
		let docURL = rootFolder.appendingPathComponent(folderPath.path)
		
		switch FileManager.default.isDirectory(url: docURL) {
		case .fileDoesNotExist:
			return []
		case .isDirectory:
			break
		case .isNotDirectory:
			throw LowDocDBError.pathMustBeADirectory
		}
		
		let urls = try fileManager.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
		let documentsData: [Data] = urls.compactMap { fileManager.contents(atPath: $0.path) }
		return documentsData
	}
	
	/// Deletes a document physically. Doesn't delete folders.
	/// - Parameter docPath: Relative path for of a document file.
	/// - Throws: `LowDocDBError.cantDeleteRoot` if trying to delete the root folder, `LowDocDBError.pathMustBeADocument` if the path is for a directory.
	public func deleteDocument(at docPath: DocPath) throws {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		if docURL == rootFolder || docPath.path == "." || docPath.path == "" {
			throw LowDocDBError.cantDeleteRoot
		}
		switch FileManager.default.isDirectory(url: docURL) {
		case .fileDoesNotExist:
			return
		case .isDirectory:
			throw LowDocDBError.pathMustBeADocument
		case .isNotDirectory:
			try fileManager.removeItem(at: docURL)
		}
	}
	
	/// Deletes a document (either regular file or directory).
	/// - Parameter docPath: Relative document path for a regular file or directory to delete
	/// - Throws: `LowDocDBError.cantDeleteRoot` if trying to delete the root folder, other errors might be thrown by the file manager too.
	public func deleteItem(at docPath: DocPath) throws {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		if docURL == rootFolder || docPath.path == "." || docPath.path == "" {
			throw LowDocDBError.cantDeleteRoot
		}
		try fileManager.removeItem(at: docURL)
	}
}
