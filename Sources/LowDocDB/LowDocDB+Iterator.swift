//
//  LowDocDB+Iterator.swift
//  
//
//  Created by Daniel Illescas Romero on 06/06/2020.
//

import struct Foundation.URL
import class Foundation.FileManager

public extension LowDocDB {
	
	/// Iterates over a given URL, providing the files paths on each iteration
	class Iterator: IteratorProtocol, Sequence {
		
		private let rootURL: URL
		private let dirEnumerator: FileManager.DirectoryEnumerator?
		private let includeFolders: Bool
		
		/// Initializes a `LowDocDb.Iterator` with a root URL, an original `FileManager.DirectoryEnumerator` and has the option to include the folders or not on the iterations.
		///
		/// This is NOT a recursive iterator.
		/// - Parameters:
		///   - rootURL: Root folder of the iterator
		///   - dirEnumerator: Directory iterator from the file manager
		///   - includeFolders: Wether to include the folders or not
		internal init(
			rootURL: URL,
			dirEnumerator: FileManager.DirectoryEnumerator?,
			includeFolders: Bool
		) {
			self.rootURL = rootURL
			self.dirEnumerator = dirEnumerator
			self.includeFolders = includeFolders
		}
		
		/// The next path
		///
		/// This may return nil if a `DocPath` couldn't be formed correctly.
		/// - Returns: The next valid path or nil if it finished or a path is invalid.
		public func next() -> DocPath? {
			guard let dirEnumerator = self.dirEnumerator else { return nil }
			if self.includeFolders {
				if let fileURL = dirEnumerator.nextObject() as? URL, let cleanPath = fileURL.path.components(separatedBy: rootURL.path).last {
					return try? DocPath(cleanPath)
				}
			} else {
				if let fileURL = dirEnumerator.nextObject() as? URL {
					if FileManager.default.isDirectory(url: fileURL) == .isDirectory {
						var tempURL: URL? = fileURL
						repeat {
							tempURL = dirEnumerator.nextObject() as? URL
						} while tempURL != nil && FileManager.default.isDirectory(url: tempURL!) == .isDirectory
						
						if let nonDirectoryURL = tempURL, let cleanPath = nonDirectoryURL.path.components(separatedBy: rootURL.path).last {
							return try? DocPath(cleanPath)
						}
					} else if let cleanPath = fileURL.path.components(separatedBy: rootURL.path).last {
						return try? DocPath(cleanPath)
					}
				}
			}
			
			return nil
		}
	}
}
