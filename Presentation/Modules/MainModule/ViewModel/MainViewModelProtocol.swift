//
//  MainViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//
import Foundation
import Combine

protocol MainViewModelProtocol {
    var viewStatePublisher: AnyPublisher<ViewState<MainViewData>, Never> { get }
    func loadData() async
}
