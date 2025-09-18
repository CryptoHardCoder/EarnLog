//
//  AppPaths.swift
//  EarnLog
//
//  Created by M3 pro on 17/09/2025.
//
import Foundation

struct AppPaths {    
    let hiddenFolder: URL
    let userAccessibleFolder: URL
    let myApplicationSupportFilesFolderURL: URL
    
    init() {
        self.hiddenFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.userAccessibleFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.myApplicationSupportFilesFolderURL = hiddenFolder.appending(path: "My Application Support Files")
    }
    
    func jsonFileURL(fileName: String) -> URL {
        myApplicationSupportFilesFolderURL.appending(path: fileName)
    }
    
    func operationFolder(for operation: DataOperation) -> URL {
        userAccessibleFolder.appending(path: operation.folderName)
    }
    
    func backupFolder(for operation: DataOperation) -> URL {
        myApplicationSupportFilesFolderURL.appending(path: operation.backupFolderName)
    }
}
