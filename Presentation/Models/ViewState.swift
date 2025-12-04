//
//  ViewState.swift
//  EarnLog
//
//  Created by M3 pro on 17/10/2025.
//
import Foundation

enum ViewState<T> {
    case ready
    case loading
    case loaded(T)
    case error(String)
    case success(String)
}
