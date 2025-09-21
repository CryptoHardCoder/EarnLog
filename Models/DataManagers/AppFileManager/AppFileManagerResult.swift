//
//  AppFileManagerResult.swift
//  EarnLog
//
//  Created by M3 pro on 21/09/2025.
//


enum AppFileManagerResult<T> {
    case success(T)
    case failure(AppFileManagerError)
    
    var isSuccess: Bool {
        switch self {
            case .success: return true
            case .failure: return false
        }
    }
    
    var error: AppFileManagerError? {
        switch self{
            case .success: return nil
            case .failure(let error): return error
        }
    }
    
    
}