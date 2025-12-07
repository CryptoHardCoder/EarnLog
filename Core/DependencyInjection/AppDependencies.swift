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
    
    private lazy var incomeManager: IncomeManagerRepository = {
        IncomeEntryManagerImpl(sideJobManager: sideJobManager, dataManager: dataManager)
    }()

    private lazy var userManager: UserManagerRepository = {
        UserManagerImpl()
    }()

    //MARK: - Use Cases
    //MARK: - UserUseCases
    lazy var userMonthlyGoalUseCase: GetUserMonthlyGoalUseCase = {
        GetUserMonthlyGoalUseCaseImpl(userManager: userManager)
    }()

    lazy var getUserInfoUseCase: GetUserInfoUseCase = {
        GetUserInfoUseCaseImpl(userManager: userManager)
    }()

    lazy var updateUserNameUseCase: UpdateUserNameUseCase = {
        UpdateUserNameUseCaseImpl(userManager: userManager)
    }()

    lazy var updateUserEmailUseCase: UpdateUserEmailUseCase = {
        UpdateUserEmailUseCaseImpl(userManager: userManager)
    }()

    lazy var updateUserPasswordUseCase: UpdateUserPasswordUseCase = {
        UpdateUserPasswordUseCaseImpl(userManager: userManager)
    }()

    lazy var setUserMonthlyGoalUseCase: SetUserMonthlyGoalUseCase = {
        SetUserMonthlyGoalUseCaseImpl(userManager: userManager)
    }()


    //MARK: - IncomeUseCases
    lazy var getAllItemsUseCase: GetAllItemsUseCase = {
        GetAllItemsUseCaseImpl(incomeManager: incomeManager)
    }()
    
    lazy var saveItemUseCase: SaveItemUseCase = {
        SaveItemUseCaseImpl(incomeManager: incomeManager)
    }()
    
    lazy var getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase = {
       GetCurrentMonthItemsUseCaseImpl(incomeManager: incomeManager) 
    }()
    
    //MARK: - SideJobsUseCases
    lazy var getActiveSideJobsUseCase: GetActiveSideJobsUseCase = {
        GetActiveSideJobsUseCaseImpl(sideJobsManager: sideJobManager)
    }()

    
    private init(){}
}
