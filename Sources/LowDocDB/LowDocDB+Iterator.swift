//
//  File.swift
//  
//
//  Created by Daniel Illescas Romero on 06/06/2020.
//

import struct Foundation.URL
import class Foundation.FileManager

public extension LowDocDB {
	class Iterator: IteratorProtocol, Sequence {
		
		private let rootURL: URL
		private let dirEnumerator: FileManager.DirectoryEnumerator?
		private let includeFolders: Bool
		
		public init(
			rootURL: URL,
			dirEnumerator: FileManager.DirectoryEnumerator?,
			includeFolders: Bool
		) {
			self.rootURL = rootURL
			self.dirEnumerator = dirEnumerator
			self.includeFolders = includeFolders
		}
		
		public func next() -> DocPath? {
			guard let dirEnumerator = self.dirEnumerator else { return nil }
			if self.includeFolders {
				if let fileURL = dirEnumerator.nextObject() as? URL, let cleanPath = fileURL.path.components(separatedBy: rootURL.path).last {
					return try? DocPath(cleanPath)
				}
			} else {
				if let fileURL = dirEnumerator.nextObject() as? URL {
					if fileURL.hasDirectoryPath {
						var tempURL: URL? = fileURL
						repeat {
							tempURL = dirEnumerator.nextObject() as? URL
						} while tempURL != nil && tempURL?.hasDirectoryPath == true
						
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
