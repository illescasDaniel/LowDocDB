//
//  FileManager+extensions.swift
//  
//
//  Created by Daniel Illescas Romero on 06/06/2020.
//

import struct Foundation.URL
import struct Foundation.ObjCBool
import class Foundation.FileManager

internal extension FileManager {
	
	enum IsDirectoryResult {
		case fileDoesNotExist
		case isDirectory
		case isNotDirectory
	}
	
	func isDirectory(url: URL) -> IsDirectoryResult {
		
		var isDirectoryResult: ObjCBool = false
		
		guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectoryResult) else {
			return .fileDoesNotExist
		}

		let isDirectory = isDirectoryResult.boolValue
		if isDirectory {
			return .isDirectory
		}
		return .isNotDirectory
	}
}
