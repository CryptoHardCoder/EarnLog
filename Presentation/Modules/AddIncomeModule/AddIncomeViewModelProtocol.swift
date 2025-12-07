//
//  AddIncomeViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 17/10/2025.
//
import Foundation
import Combine

protocol AddIncomeViewModelProtocol{
    var viewStatePublisher: AnyPublisher<ViewState<[String]>, Never> { get }
    var isPaid: Bool? { get set }
    var mainJobName: String { get }
    
    func loadData() async
    func saveNewItem(title: String, description: String?, price: Double, date: Date) async
    func selectSource(sourceName: String)
}
