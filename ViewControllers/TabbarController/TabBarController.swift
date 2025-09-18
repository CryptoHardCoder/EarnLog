//
//  TabBarController.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

final class TabBarController: UITabBarController, MemoryTrackable {
    private let disabledColor: UIColor = .designBlack
    private let enabledColor: UIColor = .designPrimary
    
    private let mainViewController = MainViewController()
    private let statisticsViewController = StatsViewController()
    private let addIncomeViewController = IncomeTrackerViewController()
    private let historyViewController = HistoryViewController()
    private let settingViewController = SettingsViewController()
    
    private weak var customTabBar: MiddleTabbarButton? {
        return MiddleTabbarButton(rootViewControllerForButton: addIncomeViewController)
    } 
    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
        
        setValue(customTabBar, forKey: "tabBar")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        let addIncomeNavigationController = UINavigationController(rootViewController: addIncomeViewController)        
        let historyNavigationController = UINavigationController(rootViewController: historyViewController)
        let settingsNavigationController = UINavigationController(rootViewController: settingViewController)
        
        // Настраиваем табы (средний таб будет скрыт)
        mainNavigationController.tabBarItem = UITabBarItem(title: "Home", 
                                                           image: UIImage(named: "Home_icon_svg"),
                                                           selectedImage: UIImage(named: "Home_icon_svg"))

        
        statisticsNavigationController.tabBarItem = UITabBarItem(title: "Stats", 
                                                                image: UIImage(named: "Stats_Icon_svg"),
                                                                selectedImage: UIImage(named: "Stats_Icon_svg"))
        addIncomeNavigationController.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: nil)
        addIncomeNavigationController.tabBarItem.isEnabled = false
        
        historyNavigationController.tabBarItem = UITabBarItem(title: "History", 
                                                              image: UIImage(named: "History_icon_svg"),
                                                              selectedImage: UIImage(named: "History_icon_svg"))
        
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", 
                                                               image: UIImage(named: "settings_tab_Icon_svg"),
                                                               selectedImage: UIImage(named: "settings_tab_Icon_svg"))
        
        setViewControllers([
            mainNavigationController,
            statisticsNavigationController,
            addIncomeNavigationController,  // Средняя позиция
            historyNavigationController,
            settingsNavigationController
        ], animated: false)
        
        // Устанавливаем начальный выбранный индекс (не средний)
        selectedIndex = 0
    }
    
    private func setupTabBarAppearance() {
        tabBar.layer.borderColor = UIColor.gray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.tintColor = .designPrimary
        tabBar.backgroundColor = .clear
    }
    
    deinit {
        trackDeallocation()
    }
}




//final class TabBarController: UITabBarController, MemoryTrackable {
//    private let addButtonDiametr: CGFloat =  40.0
//    private let disabledColor: UIColor = .designBlack
//    private let enabledColor: UIColor = .designPrimary
//    
//    private lazy var addButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .designPrimary
//        button.layer.cornerRadius = addButtonDiametr / 2
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.shadowColor = UIColor.designPrimary.withAlphaComponent(0.6).cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 5)
//        button.layer.shadowRadius = 20
//        button.layer.shadowOpacity = 1
//        return button
//    }()
//    
//    private lazy var addImageView: UIImageView = {
//       let imageView = UIImageView()
//        let config = UIImage.SymbolConfiguration(scale: .large)
//        imageView.image = UIImage(named: "+_Icon_svg")?.withRenderingMode(.alwaysOriginal)
////        imageView.image = UIImage(systemName: "plus", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .clear
//        imageView.translatesAutoresizingMaskIntoConstraints = false        
//        
//        return imageView
//    }()
//    
//    let mainViewController = MainViewController()
//    let statisticsViewController = StatsViewController()
//    let addIncomeViewController = IncomeTrackerViewController()
//    let historyViewController = HistoryViewController()
//    let settingViewController = SettingsViewController()
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        trackCreation()
//        setValue(CustomTabbar(), forKey: "tabBar")
//        
//    }
//        
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        makeUI()
//        tabBar.layer.borderColor = UIColor.gray.cgColor
//        tabBar.layer.borderWidth = 1
//        tabBar.tintColor = .designPrimary
//        tabBar.backgroundColor = .clear
//        
//        
//        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
//        let statisticsViewController = UINavigationController(rootViewController: statisticsViewController)
//        //FIXME: Поменять на соответствующий контроллер
//        let addIncomeViewController = UINavigationController(rootViewController: addIncomeViewController)
//        let historyNavigationController = UINavigationController(rootViewController: historyViewController)
//        let settingViewController = UINavigationController(rootViewController: settingViewController)
//        
//        
//        mainNavigationController.tabBarItem = UITabBarItem(title: "add_tab".localized,
//                                                           image: UIImage(named: "Home_icon_svg"),
//                                                           selectedImage: UIImage(named: "Home_icon_svg"))
////        mainNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: -20, left: 0, bottom: 20, right: 0)
////        mainNavigationController.tabBarItem.standardAppearance?.shadowColor = .black
//        
//        
//        statisticsViewController.tabBarItem = UITabBarItem(title: "stats_tab".localized,
//                                                           image: UIImage(named: "Stats_Icon_svg"),
//                                                           selectedImage: UIImage(named: "Stats_Icon_svg"))
////        statisticsViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
//        
//        historyNavigationController.tabBarItem = UITabBarItem(title: "history_tab".localized,
//                                                              image: UIImage(named: "History_icon_svg"),
//                                                              selectedImage: UIImage(named: "History_icon_svg"))
////        historyNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
//        
//        settingViewController.tabBarItem = UITabBarItem(title: "settings_tab".localized,
//                                                        image: UIImage(named: "settings_tab_Icon_svg"),
//                                                        selectedImage: UIImage(named: "settings_tab_Icon_svg"))
////        settingViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//        
////        tabBarController?.tabBar.heightAnchor.constraint(equalToConstant: 200).isActive
////        tabBar.heightAnchor.constraint(equalToConstant: 200).isActive
//        
//        setViewControllers(
//            [mainNavigationController,
//             statisticsViewController,
//             addIncomeViewController,
//             historyNavigationController,
//             settingViewController],
//            animated: true)
//        
//        
//    }
//    
//    private func makeUI(){
//        //        view.addSubview(addButton)     
//        if addButton.superview == nil {
//            tabBar.addSubview(addButton)
//            addButton.addSubview(addImageView)
//            //MARK: Констрейнты + буттона
//            NSLayoutConstraint.activate([
//                addButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
//                addButton.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor, constant: -30),
//                
//                addButton.heightAnchor.constraint(equalToConstant: addButtonDiametr),
//                addButton.widthAnchor.constraint(equalToConstant: addButtonDiametr)
//            ])
//            
//            //MARK: Constraints for addImageView in addButton
//            NSLayoutConstraint.activate([
//                addImageView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
//                addImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
//                
//                addImageView.widthAnchor.constraint(equalToConstant: addButtonDiametr / 2),
//                addImageView.heightAnchor.constraint(equalToConstant: addButtonDiametr / 2)
//            ])
//        }
//    }
//    
//    deinit {
//        trackDeallocation() // для анализа на memory leaks
//    }
//
//
//}

//extension TabBarController: UITabBarControllerDelegate {
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        let selectedIndex = self.tabBar.items?.firstIndex(of: item) // 1
//        if selectedIndex == 1 { // 2
//            middleButton.backgroundColor = greenColor // 3
//        } else {
//            middleButton.backgroundColor = redColor // 4
//        }
//    }
//}


@available(iOS 17.0, *)
#Preview {
    TabBarController()
    
}
