//
//  ChangeAppearanceViewController.swift
//  EarnLog
//
//  Created by M3 pro on 23/11/2025.
//
import UIKit

final class ChangeAppearanceViewController: UIViewController {

    private let viewModel: any ChangeAppearanceViewModelProtocol

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(viewModel: any ChangeAppearanceViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI(){
        view.backgroundColor = DSColors.appBackground
        title = "Appearance"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ChangeAppearanceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.themes.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let themeNames = viewModel.themes
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = themeNames[indexPath.row].name
        if themeNames[indexPath.row].name == viewModel.userTheme.name {
            cell.accessoryType = .checkmark
        }
        cellConfig.textProperties.color = DSColors.appTextPrimary
        cellConfig.textProperties.font = DSTypography.heading3(weight: .semibold).font
        cell.contentConfiguration = cellConfig
        cell.tintColor = DSColors.appPrimary
        cell.backgroundConfiguration = .clear()

        return cell
    }
}

extension ChangeAppearanceViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.visibleCells.forEach { $0.accessoryType = .none }

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark

        let selectedTheme = viewModel.themes[indexPath.row]
        ThemeManager.shared.apply(theme: selectedTheme)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

