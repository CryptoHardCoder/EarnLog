//
//  AppPaths.swift
//  EarnLog
//
//  Created by M3 pro on 17/09/2025.
//
import Foundation

struct LocalStoragePathBuilderImpl: AppPathsBuilderRepository {    

    private let hiddenFolder: URL
    private let userAccessibleFolder: URL
    let myApplicationSupportFilesFolderURL: URL
    
    init() {
        self.hiddenFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.userAccessibleFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.myApplicationSupportFilesFolderURL = hiddenFolder.appending(path: "My Application Support Files")
    }
    
    func jsonFileLocation(fileName: String) -> StorageLocation {
        let path = myApplicationSupportFilesFolderURL.appending(path: fileName).path
        return .local(path: path)
    }
    
    func userOperationLocation(for operation: DataOperation) -> StorageLocation {
        let path = userAccessibleFolder.appending(path: operation.folderName).path
        return .local(path: path)
    }
    
    func backupLocation(for operation: DataOperation) -> StorageLocation {
        let path = myApplicationSupportFilesFolderURL.appending(path: operation.backupFolderName).path
        return .local(path: path)
    }
}
