import XCTest
@testable import LowDocDB

final class LowDocDBTests: XCTestCase {
	
	let rootFolder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent("doc.db")
	
	// MARK: addDocument
	
	func testAddDocuments() {
		addDocumentsWithLowDocDBAndCheckWithFileManager(docPath: .root)
	}
	
	func testAddDocumentsAtSubfolders() {
		do {
			var folder = "/myFolder1"
			for i in 0..<10 {
				addDocumentsWithLowDocDBAndCheckWithFileManager(docPath: try DocPath(folder))
				folder += "/other\(i)"
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	// MARK: document at path
	
	func testDocumentsAtPath() {
		addDocumentsWithFileManagerAndCheckWithLowDB(docPath: .root)
	}
	
	func testDocumentsAtSubfolders() {
		do {
			var folder = "/myFolder1"
			for i in 0..<10 {
				addDocumentsWithFileManagerAndCheckWithLowDB(docPath: try DocPath(folder))
				folder += "/other\(i)"
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	// MARK: documents at path
	
	func testMultipleDocumentsAtPath() {
		addMultipleDocumentsWithFileManagerAndCheckWithLowDB(docPath: .root)
	}
	
	func testMultipleDocumentsAtSubfolders() {
		do {
			var folder = "/myFolder1"
			for i in 0..<10 {
				addMultipleDocumentsWithFileManagerAndCheckWithLowDB(docPath: try DocPath(folder))
				folder += "/other\(i)"
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	// MARK: document exists
	
	func testDocumentsExistAtPath() {
		addDocumentsWithFileManagerAndCheckIfTheyExistWithLowDB(docPath: .root)
	}
	
	func testDocumentsExistAtSubfolders() {
		do {
			var folder = "/myFolder1"
			for i in 0..<10 {
				addDocumentsWithFileManagerAndCheckIfTheyExistWithLowDB(docPath: try DocPath(folder))
				folder += "/other\(i)"
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	// MARK: document is folder
	
	func testDocumentIsFolder() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			XCTAssertTrue(lowDocDB.documentIsFolder(.root))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertTrue(lowDocDB.documentIsFolder(try DocPath("someNewFolder")))
			
			try _createFile(docPath: try DocPath("someNewFolder/otherFile"), data: Data("test".utf8), rootFolder: rootFolder)
			XCTAssertFalse(lowDocDB.documentIsFolder(try DocPath("someNewFolder/otherFile")))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertTrue(lowDocDB.documentIsFolder(try DocPath("someNewFolder/other")))
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	// MARK: delete document (not folder)
	
	func testDeleteDocument() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertNil(try? lowDocDB.deleteDocument(at: try DocPath("someNewFolder")))
			
			try _createFile(docPath: try DocPath("someNewFolder/otherFile"), data: Data("test".utf8), rootFolder: rootFolder)
			XCTAssertNotNil(try? lowDocDB.deleteDocument(at: try DocPath("someNewFolder/otherFile")))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertNil(try? lowDocDB.deleteDocument(at: try DocPath("someNewFolder/other")))
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	// MARK: delete item (document or folder)
	
	func testDeleteItem() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertNotNil(try? lowDocDB.deleteItem(at: try DocPath("someNewFolder")))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
			
			try _createFile(docPath: try DocPath("someNewFolder/otherFile"), data: Data("test".utf8), rootFolder: rootFolder)
			XCTAssertNotNil(try? lowDocDB.deleteItem(at: try DocPath("someNewFolder/otherFile")))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			XCTAssertNotNil(try? lowDocDB.deleteItem(at: try DocPath("someNewFolder/other")))
			
			XCTAssertNil(try? lowDocDB.deleteItem(at: .root))
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	// MARK: document paths
	
	func testDocumentPathsNotIncludingFolders() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
						
			let docPaths: [DocPath] = [
				try DocPath("someNewFolder/otherFile"),
				try DocPath("someNewFolder/otherFile2")
			]
			try _createFile(docPath: docPaths[0], data: Data("test".utf8), rootFolder: rootFolder)
			try _createFile(docPath: docPaths[1], data: Data("test2".utf8), rootFolder: rootFolder)
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			try _createFile(docPath: try DocPath("someNewFolder/other/otherFile3"), data: Data("test3".utf8), rootFolder: rootFolder)
			
			let paths = try lowDocDB.documentPaths(at: try DocPath("someNewFolder"), includingFolders: false)
			XCTAssertEqual(paths.count, 2)
			
			for docPath in paths {
				XCTAssertTrue(docPaths.map(\.path).contains(docPath.path))
				switch docPath.path {
				case "someNewFolder/otherFile":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test".utf8))
				case "someNewFolder/otherFile2":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test2".utf8))
				default:
					XCTFail("incorrect path!")
				}
			}
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	func testDocumentPathsIncludingFolders() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
						
			let docPaths: [DocPath] = [
				try DocPath("someNewFolder/otherFile"),
				try DocPath("someNewFolder/otherFile2"),
				try DocPath("someNewFolder/other")
			]
			try _createFile(docPath: docPaths[0], data: Data("test".utf8), rootFolder: rootFolder)
			try _createFile(docPath: docPaths[1], data: Data("test2".utf8), rootFolder: rootFolder)
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			try _createFile(docPath: docPaths[2].appending("otherFile3"), data: Data("test3".utf8), rootFolder: rootFolder)
			
			let paths = try lowDocDB.documentPaths(at: try DocPath("someNewFolder"), includingFolders: true)
			XCTAssertEqual(paths.count, 3)
			
			for docPath in paths {
				XCTAssertTrue(docPaths.map(\.path).contains(docPath.path))
				switch docPath.path {
				case "someNewFolder/otherFile":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test".utf8))
				case "someNewFolder/otherFile2":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test2".utf8))
				case "someNewFolder/other":
					break
				default:
					XCTFail("incorrect path!")
				}
			}
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	// MARK: Document enumerator
	
	func testDocumentPathsEnumeratorNotIncludingFolders() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
						
			let docPaths: [DocPath] = [
				try DocPath("/someNewFolder/otherFile"),
				try DocPath("/someNewFolder/otherFile2")
			]
			try _createFile(docPath: docPaths[0], data: Data("test".utf8), rootFolder: rootFolder)
			try _createFile(docPath: docPaths[1], data: Data("test2".utf8), rootFolder: rootFolder)
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			try _createFile(docPath: try DocPath("someNewFolder/other/otherFile3"), data: Data("test3".utf8), rootFolder: rootFolder)
			
			let pathsEnumerator = try lowDocDB.enumerator(at: try DocPath("someNewFolder"), includeFolders: false)
			
			var count = 0
			
			for docPath in pathsEnumerator {
				print("_>", docPath)
				XCTAssertTrue(docPaths.map(\.path).contains(docPath.path))
				switch docPath.path {
				case "/someNewFolder/otherFile":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test".utf8))
				case "/someNewFolder/otherFile2":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test2".utf8))
				default:
					XCTFail("incorrect path!")
				}
				count += 1
			}
			
			XCTAssertEqual(count, 2)
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	func testDocumentPathsEnumeratorIncludingFolders() {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder"), withIntermediateDirectories: true, attributes: nil)
						
			let docPaths: [DocPath] = [
				try DocPath("/someNewFolder/otherFile"),
				try DocPath("/someNewFolder/otherFile2"),
				try DocPath("/someNewFolder/other")
			]
			try _createFile(docPath: docPaths[0], data: Data("test".utf8), rootFolder: rootFolder)
			try _createFile(docPath: docPaths[1], data: Data("test2".utf8), rootFolder: rootFolder)
			
			try fileManager.createDirectory(at: rootFolder.appendingPathComponent("someNewFolder/other"), withIntermediateDirectories: true, attributes: nil)
			try _createFile(docPath: docPaths[2].appending("otherFile3"), data: Data("test3".utf8), rootFolder: rootFolder)
			
			let pathsEnumerator = try lowDocDB.enumerator(at: try DocPath("someNewFolder"), includeFolders: true)
			
			var count = 0
			
			for docPath in pathsEnumerator {
				XCTAssertTrue(docPaths.map(\.path).contains(docPath.path))
				switch docPath.path {
				case "/someNewFolder/otherFile":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test".utf8))
				case "/someNewFolder/otherFile2":
					XCTAssertEqual(fileManager.contents(atPath: rootFolder.appendingPathComponent(docPath.path).path), Data("test2".utf8))
				case "/someNewFolder/other":
					break
				default:
					XCTFail("incorrect path!")
				}
				count += 1
			}
			
			XCTAssertEqual(count, 3)
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	// MARK: - Convenience
	
	private func addDocumentsWithLowDocDBAndCheckWithFileManager(docPath: DocPath) {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try _addDocumentAndCheckWithFileManager(
				docPath: try docPath.appending("doc1.txt"),
				data: Data("daniel illescas".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentAndCheckWithFileManager(
				docPath: try docPath.appending("doc2.txt"),
				data: Data("something here".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentAndCheckWithFileManager(
				docPath: try docPath.appending("doc3.txt"),
				data: Data("lol".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	private func _addDocumentAndCheckWithFileManager(
		docPath: DocPath,
		data: Data,
		rootFolder: URL,
		lowDocDB: LowDocDB,
		fileManager: FileManager = FileManager.default
	) throws {

		try lowDocDB.addDocument(at: docPath, data: data)

		let fullDocPath = rootFolder.appendingPathComponent(docPath.path).path
		XCTAssertTrue(fileManager.fileExists(atPath: fullDocPath))
		XCTAssertEqual(fileManager.contents(atPath: fullDocPath), data)
	}
	
	//
	
	private func addDocumentsWithFileManagerAndCheckWithLowDB(docPath: DocPath) {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try _addDocumentWithFileManagerAndCheckWithLowDocDB(
				docPath: try docPath.appending("doc1.txt"),
				data: Data("daniel illescas".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentWithFileManagerAndCheckWithLowDocDB(
				docPath: try docPath.appending("doc2.txt"),
				data: Data("something here".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentWithFileManagerAndCheckWithLowDocDB(
				docPath: try docPath.appending("doc3.txt"),
				data: Data("lol".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	private func _addDocumentWithFileManagerAndCheckWithLowDocDB(
		docPath: DocPath,
		data: Data,
		rootFolder: URL,
		lowDocDB: LowDocDB,
		fileManager: FileManager = FileManager.default
	) throws {

		let docURL = rootFolder.appendingPathComponent(docPath.path)
		try fileManager.createDirectory(at: docURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		XCTAssertTrue(fileManager.createFile(atPath: docURL.path, contents: data, attributes: nil))

		XCTAssertEqual(lowDocDB.document(at: docPath), data)
	}
	
	//
	
	private func addMultipleDocumentsWithFileManagerAndCheckWithLowDB(docPath: DocPath) {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			let dataArray: [Data] = [
				Data("lol".utf8),
				Data("something here".utf8),
				Data("daniel illescas12312".utf8)
			]
			try _createFile(
				docPath: try docPath.appending("doc1.txt"),
				data: dataArray[0],
				rootFolder: rootFolder
			)
			try _createFile(
				docPath: try docPath.appending("doc2.txt"),
				data: dataArray[1],
				rootFolder: rootFolder
			)
			try _createFile(
				docPath: try docPath.appending("doc3.txt"),
				data: dataArray[2],
				rootFolder: rootFolder
			)
			let retrievedDocs = try lowDocDB.documents(at: docPath).sorted(by: { $0.count < $1.count })
			XCTAssertEqual(dataArray, retrievedDocs)
			
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	private func _createFile(
		docPath: DocPath,
		data: Data,
		rootFolder: URL,
		fileManager: FileManager = FileManager.default
	) throws {
		let docURL = rootFolder.appendingPathComponent(docPath.path)
		try fileManager.createDirectory(at: docURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		XCTAssertTrue(fileManager.createFile(atPath: docURL.path, contents: data, attributes: nil))
	}
	
	//
	
	private func addDocumentsWithFileManagerAndCheckIfTheyExistWithLowDB(docPath: DocPath) {
		let fileManager = FileManager.default
		try? fileManager.removeItem(at: rootFolder)
		do {
			try fileManager.createDirectory(at: rootFolder, withIntermediateDirectories: false, attributes: nil)
			let lowDocDB = LowDocDB(rootFolder: rootFolder, options: .init(maxDepth: .max))
			
			try _addDocumentWithFileManagerAndCheckIfTheyExistWithLowDocDB(
				docPath: try docPath.appending("doc1.txt"),
				data: Data("daniel illescas".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentWithFileManagerAndCheckIfTheyExistWithLowDocDB(
				docPath: try docPath.appending("doc2.txt"),
				data: Data("something here".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try _addDocumentWithFileManagerAndCheckIfTheyExistWithLowDocDB(
				docPath: try docPath.appending("doc3.txt"),
				data: Data("lol".utf8),
				rootFolder: rootFolder, lowDocDB: lowDocDB
			)
			try? fileManager.removeItem(at: rootFolder)
		} catch {
			XCTFail("\(error)")
			try? fileManager.removeItem(at: rootFolder)
		}
	}
	
	private func _addDocumentWithFileManagerAndCheckIfTheyExistWithLowDocDB(
		docPath: DocPath,
		data: Data,
		rootFolder: URL,
		lowDocDB: LowDocDB,
		fileManager: FileManager = FileManager.default
	) throws {

		let docURL = rootFolder.appendingPathComponent(docPath.path)
		try fileManager.createDirectory(at: docURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		XCTAssertTrue(fileManager.createFile(atPath: docURL.path, contents: data, attributes: nil))

		XCTAssertTrue(lowDocDB.documentExist(at: docPath))
	}
	
	// MARK: - All tests
	
	static var allTests = [
		("testAddDocuments", testAddDocuments),
		("testAddDocumentsAtSubfolders", testAddDocumentsAtSubfolders),
		("testDocumentsAtPath", testDocumentsAtPath),
		("testDocumentsAtSubfolders", testDocumentsAtSubfolders),
		("testMultipleDocumentsAtPath", testMultipleDocumentsAtPath),
		("testMultipleDocumentsAtSubfolders", testMultipleDocumentsAtSubfolders),
		("testDocumentsExistAtPath", testDocumentsExistAtPath),
		("testDocumentsExistAtSubfolders", testDocumentsExistAtSubfolders),
		("testDocumentIsFolder", testDocumentIsFolder),
		("testDeleteDocument", testDeleteDocument),
		("testDeleteItem", testDeleteItem),
		("testDocumentPathsNotIncludingFolders", testDocumentPathsNotIncludingFolders),
		("testDocumentPathsIncludingFolders", testDocumentPathsIncludingFolders),
		("testDocumentPathsEnumeratorNotIncludingFolders", testDocumentPathsEnumeratorNotIncludingFolders),
		("testDocumentPathsEnumeratorIncludingFolders", testDocumentPathsEnumeratorIncludingFolders)
	]
}
