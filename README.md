# LowDocDB

Low level document based NoSQL database.

This is a WIP project, so things may change during development.

## Interface
```swift
public class LowDocDB {

    public init(rootFolder: URL, options: LowDocDBOptions = .init())

    public func addDocument(at docPath: DocPath, data: Data) throws

    public func document(at docPath: DocPath) -> Data?

    public func documentExist(at docPath: DocPath) -> Bool

    public func documentPaths(at folderPath: DocPath, includingFolders: Bool) throws -> [DocPath]

    public func documentIsFolder(_ docPath: DocPath) -> Bool

    public func enumerator(at folderPath: DocPath, includeFolders: Bool) throws -> LowDocDB.Iterator

    public func documents(at folderPath: DocPath) throws -> [Data]

    public func deleteDocument(at docPath: DocPath) throws

    public func deleteItem(at docPath: DocPath) throws
}
```
