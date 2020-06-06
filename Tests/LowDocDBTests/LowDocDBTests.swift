import XCTest
@testable import LowDocDB

final class LowDocDBTests: XCTestCase {
	
	let rootFolder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent("doc.db")
	
	func testExample() {
		let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: 8))
		do {
			try lowDocDB.addDocument(at: try DocPath("test.txt"), data: Data("holaaa".utf8))
			
			print(
				try lowDocDB.documentPaths(at: .root, includingFolders: false)
			)
			
			for path in try lowDocDB.enumerator(at: .root, includeFolders: true) {
				print(path)
			}
			print("-----")
			for path in try lowDocDB.enumerator(at: .root, includeFolders: false) {
				print(path)
			}
		} catch {
			print(error)
		}
	}
	
	static var allTests = [
		("testExample", testExample),
	]
}
