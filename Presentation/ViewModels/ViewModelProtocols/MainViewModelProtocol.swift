//
//  MainViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//
import Foundation

protocol MainViewModelProtocol {
    associatedtype T
    var viewState: ViewState<T> { get }
    func loadData() async
}
