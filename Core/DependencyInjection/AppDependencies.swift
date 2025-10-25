//
//  AppDependencies.swift
//  EarnLog
//
//  Created by M3 pro on 18/09/2025.
//

import Foundation

class AppDependencies {
    static let shared = AppDependencies()
    
    //MARK: - Repositories
    private lazy var dataManager: CoreDataManagerRepository = {
        CoreDataManager()
    }()
    
    private lazy var sideJobManager: SideJobManagerRepository = {
        SideJobManagerImpl(dataManager: dataManager)
    }()
    
    private lazy var incomeManager: IncomeManagerProtocol = {
        IncomeEntryManagerImpl(sideJobManager: sideJobManager, dataManager: dataManager)
    }()
    
    //MARK: - Use Cases
    //MARK: - GoalUseCases
    private lazy var userMonthlyGoalUseCase: UserMonthlyGoalUseCase = {
        UserMonthlyGoalUseCaseImpl()
    }()
    
    //MARK: - ItemUseCases
    private lazy var getAllItemsUseCase: GetAllItemsUseCase = {
        GetAllItemsUseCaseImpl(incomeManager: incomeManager)
    }()
    
    private lazy var saveItemUseCase: SaveItemUseCase = {
        SaveItemUseCaseImpl(incomeManager: incomeManager)
    }()
    
    private lazy var getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase = {
       GetCurrentMonthItemsUseCaseImpl(incomeManager: incomeManager) 
    }()
    
    //MARK: - SideJobsUseCases
    private lazy var getActiveSideJobsUseCase: GetActiveSideJobsUseCase = {
        GetActiveSideJobsUseCaseImpl(sideJobsManager: sideJobManager)
    }()
    
    
    // ViewModels
    lazy var mainViewModel: MainViewModel = {
        MainViewModel(getCurrentMonthItemsUseCase: getCurrentMonthItemsUseCase, 
                      userMonthlyGoalUseCase: userMonthlyGoalUseCase)
    }()
    
    lazy var addIncomeViewModel: AddIncomeViewModel = {
        AddIncomeViewModel(getAllActiveSideJobsUseCase: getActiveSideJobsUseCase, 
                           saveItemUseCase: saveItemUseCase)
    }()
    
    private init(){}
}
