//
//  MemoryTrackable.swift
//  EarnLog
//
//  Created by M3 pro on 24/08/2025.
//


protocol MemoryTrackable: AnyObject {
    func trackCreation()
    func trackDeallocation()
}

extension MemoryTrackable {
    func trackCreation() {
    #if DEBUG
        print("📍 CREATED: \(String(describing: type(of: self)))")
    #endif
    }
        func trackDeallocation() {
    #if DEBUG
            print("✅ DEINIT: \(String(describing: type(of: self)))")
    #endif
        }
}
