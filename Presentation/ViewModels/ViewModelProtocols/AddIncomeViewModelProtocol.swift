//
//  AddIncomeViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 17/10/2025.
//
import Foundation

protocol AddIncomeViewModelProtocol{
    associatedtype T
    var viewState: ViewState<T> { get }
    func loadData() async
    func saveNewItem(title: String, description: String?, price: Double, date: Date) async
    func selectSource(sourceName: String)
}
