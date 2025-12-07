//
//  ViewModelFactoryProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//
import Foundation

protocol ViewModelFactoryProtocol {
    func makeMainViewModel() -> any MainViewModelProtocol
    func makeAddIncomeViewModel() -> any AddIncomeViewModelProtocol
}
