//import UIKit
//
//// MARK: - Custom Tab Bar Item
//struct CustomTabBarItem {
//    let title: String
//    let image: UIImage?
//    let selectedImage: UIImage?
//    let viewController: UIViewController
//}
//
//// MARK: - Custom Tab Bar Controller
//class CustomTabBarController: UIViewController {
//    
//    // MARK: - Properties
//    private let customTabBar = CustomTabBar()
//    private let containerView = UIView()
//    
//    private var tabBarItems: [CustomTabBarItem] = []
//    private var viewControllers: [UIViewController] = []
//    private var selectedIndex: Int = 0 {
//        didSet {
//            updateSelectedViewController()
//        }
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupConstraints()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        // Container for view controllers
//        containerView.backgroundColor = .systemBackground
//        view.addSubview(containerView)
//        
//        // Custom tab bar
//        customTabBar.delegate = self
//        view.addSubview(customTabBar)
//        
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        customTabBar.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Container constraints
//            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
//            
//            // Tab bar constraints
//            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            customTabBar.heightAnchor.constraint(equalToConstant: 60)
//        ])
//    }
//    
//    // MARK: - Public Methods
//    func setTabBarItems(_ items: [CustomTabBarItem]) {
//        // Remove old view controllers
//        viewControllers.forEach { removeChildViewController($0) }
//        
//        tabBarItems = items
//        viewControllers = items.map { $0.viewController }
//        
//        // Setup new view controllers
//        viewControllers.forEach { addViewController($0) }
//        
//        // Update tab bar
//        customTabBar.setItems(items)
//        
//        // Select first item
//        if !items.isEmpty {
//            selectedIndex = 0
//        }
//    }
//    
//    private func addViewController(_ viewController: UIViewController) {
//        addChild(viewController)
//        containerView.addSubview(viewController.view)
//        viewController.view.frame = containerView.bounds
//        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        viewController.view.isHidden = true
//        viewController.didMove(toParent: self)
//    }
//    
//    private func removeChildViewController(_ viewController: UIViewController) {
//        viewController.willMove(toParent: nil)
//        viewController.view.removeFromSuperview()
//        viewController.removeFromParent()
//    }
//    
//    private func updateSelectedViewController() {
//        // Hide all view controllers
//        viewControllers.forEach { $0.view.isHidden = true }
//        
//        // Show selected view controller
//        if selectedIndex < viewControllers.count {
//            viewControllers[selectedIndex].view.isHidden = false
//        }
//        
//        // Update tab bar selection
//        customTabBar.setSelectedIndex(selectedIndex)
//    }
//}
//
//// MARK: - CustomTabBarDelegate
//extension CustomTabBarController: CustomTabBarDelegate {
//    func customTabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int) {
//        selectedIndex = index
//    }
//}
//
//// MARK: - Custom Tab Bar Delegate
//protocol CustomTabBarDelegate: AnyObject {
//    func customTabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int)
//}
//
//// MARK: - Custom Tab Bar View
//class CustomTabBar: UIView {
//    
//    // MARK: - Properties
//    weak var delegate: CustomTabBarDelegate?
//    private let stackView = UIStackView()
//    private var tabBarButtons: [CustomTabBarButton] = []
//    private var selectedIndex: Int = 0
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        backgroundColor = .systemBackground
//        
//        // Add border
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: -1)
//        layer.shadowOpacity = 0.1
//        layer.shadowRadius = 0
//        
//        
//        // Setup stack view
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.alignment = .fill
//        addSubview(stackView)
//        
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Public Methods
//    func setItems(_ items: [CustomTabBarItem]) {
//        // Remove old buttons
//        tabBarButtons.forEach { $0.removeFromSuperview() }
//        tabBarButtons.removeAll()
//        
//        // Create new buttons
//        for (index, item) in items.enumerated() {
//            let button = CustomTabBarButton()
//            button.configure(with: item)
//            button.tag = index
//            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
//            
//            stackView.addArrangedSubview(button)
//            tabBarButtons.append(button)
//        }
//        
//        // Select first item
//        if !tabBarButtons.isEmpty {
//            setSelectedIndex(0)
//        }
//    }
//    
//    func setSelectedIndex(_ index: Int) {
//        selectedIndex = index
//        
//        for (i, button) in tabBarButtons.enumerated() {
//            button.setSelected(i == index)
//        }
//    }
//    
//    @objc private func tabBarButtonTapped(_ sender: CustomTabBarButton) {
//        delegate?.customTabBar(self, didSelectItemAt: sender.tag)
//    }
//}
//
//// MARK: - Custom Tab Bar Button
//class CustomTabBarButton: UIButton {
//    
//    // MARK: - Properties
//    private let iconImageView = UIImageView()
//    private let titleLbl = UILabel()
//    private let stackView = UIStackView()
//    
//    private var normalImage: UIImage?
//    private var selectedImage: UIImage?
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.point(inside: point, with: event) {
//            return self
//        }
//        return super.hitTest(point, with: event)
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        // Setup stack view
//        stackView.axis = .vertical
//        stackView.alignment = .center
//        stackView.spacing = 4
//        addSubview(stackView)
//        
//        // Setup image view
//        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.tintColor = .systemGray
//        
//        // Setup title label
//        titleLbl.font = UIFont.systemFont(ofSize: 10)
//        titleLbl.textColor = .systemGray
//        titleLbl.textAlignment = .center
//        
//        stackView.addArrangedSubview(iconImageView)
//        stackView.addArrangedSubview(titleLbl)
//        
//        // Constraints
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 24),
//            iconImageView.heightAnchor.constraint(equalToConstant: 24)
//        ])
//    }
//    
//    // MARK: - Public Methods
//    func configure(with item: CustomTabBarItem) {
//        titleLbl.text = item.title
//        normalImage = item.image
//        selectedImage = item.selectedImage ?? item.image
//        iconImageView.image = normalImage
//    }
//    
//    func setSelected(_ selected: Bool) {
//        let color: UIColor = selected ? .systemBlue : .systemGray
//        let image = selected ? selectedImage : normalImage
//        
//        titleLbl.textColor = color
//        iconImageView.tintColor = color
//        iconImageView.image = image
//        
//        // Add animation
//        UIView.animate(withDuration: 0.2) {
//            self.transform = selected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
//        }
//    }
//}
//
////// MARK: - Usage Example
////class SceneDelegate: UIResponder, UIWindowSceneDelegate {
////    var window: UIWindow?
////
////    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
////        guard let windowScene = (scene as? UIWindowScene) else { return }
////        
////        window = UIWindow(windowScene: windowScene)
////        
////        // Create view controllers
////        let homeVC = UIViewController()
////        homeVC.view.backgroundColor = .systemRed
////        homeVC.title = "Home"
////        
////        let searchVC = UIViewController()
////        searchVC.view.backgroundColor = .systemBlue
////        searchVC.title = "Search"
////        
////        let profileVC = UIViewController()
////        profileVC.view.backgroundColor = .systemGreen
////        profileVC.title = "Profile"
////        
////        // Create tab bar items
////        let tabBarItems = [
////            CustomTabBarItem(
////                title: "Home",
////                image: UIImage(systemName: "house"),
////                selectedImage: UIImage(systemName: "house.fill"),
////                viewController: homeVC
////            ),
////            CustomTabBarItem(
////                title: "Search",
////                image: UIImage(systemName: "magnifyingglass"),
////                selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"),
////                viewController: searchVC
////            ),
////            CustomTabBarItem(
////                title: "Profile",
////                image: UIImage(systemName: "person"),
////                selectedImage: UIImage(systemName: "person.fill"),
////                viewController: profileVC
////            )
////        ]
////        
////        // Setup custom tab bar controller
////        let customTabBarController = CustomTabBarController()
////        customTabBarController.setTabBarItems(tabBarItems)
////        
////        window?.rootViewController = customTabBarController
////        window?.makeKeyAndVisible()
////    }
////}
