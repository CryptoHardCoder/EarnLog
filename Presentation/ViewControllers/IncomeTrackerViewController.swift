
import UIKit


class IncomeTrackerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MemoryTrackable {
    let tableView = UITableView()
    var records: [Record] = [
        Record(title: "Машина", date: Date()),
        Record(title: "Аренда", date: Date())
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Записи"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DateCell.self, forCellReuseIdentifier: DateCell.identifier)
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.identifier, for: indexPath) as? DateCell else {
            return UITableViewCell()
        }

        let record = records[indexPath.row]
        cell.titleLabel.text = record.title
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        cell.dateLabel.text = formatter.string(from: record.date)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDatePicker(for: indexPath)
    }
    
    // MARK: - Date Picker

    func showDatePicker(for indexPath: IndexPath) {
        let alert = UIAlertController(title: "Выберите дату", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = records[indexPath.row].date
        picker.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.width - 20, height: 160)
        alert.view.addSubview(picker)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
            self.records[indexPath.row].date = picker.date
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }))

        present(alert, animated: true)
    }
}


struct Record {
    var title: String
    var date: Date
}

class DateCell: UITableViewCell {
    static let identifier = "DateCell"
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .systemBlue
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
