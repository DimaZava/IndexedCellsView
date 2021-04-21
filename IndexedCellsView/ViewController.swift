//
//  ViewController.swift
//  IndexedCellsView
//
//  Created by Dmitry Zawadsky on 22.04.2021.
//

import UIKit

class ViewConroller: UIViewController {

    // MARK: Constants
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let indexedCellsView = IndexedCellsView()
    
    // MARK: Properties
    private var countries = [CountryViewModel]()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
}

// MARK: - UITableViewDelegate
extension ViewConroller: UITableViewDelegate {
}

// MARK: - UITableViewDataSource
extension ViewConroller: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self),
                                                 for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].countryName
        cell.detailTextLabel?.text = countries[indexPath.row].countryCode
        return cell
    }
}

// MARK: - IndexedCellsViewDelegate
extension ViewConroller: IndexedCellsViewDelegate {
 
    func didSelectIndexItem(_ selectedTitle: String) {
        guard let rowToScroll = countries.firstIndex(where: { $0.countryName.prefix(1) == selectedTitle }) else {
            return
        }
        tableView.scrollToRow(at: .init(row: rowToScroll, section: 0), at: .top, animated: true)
    }
}

// MARK: - Private Extension
private extension ViewConroller {
    
    func setupInitialState() {
        loadData()
        
        view.addSubview(indexedCellsView)
        indexedCellsView.delegate = self
        indexedCellsView.translatesAutoresizingMaskIntoConstraints = false
        indexedCellsView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        indexedCellsView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        indexedCellsView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        indexedCellsView.updateTitles(with: countries.map { $0.countryName })
        
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: indexedCellsView.leftAnchor).isActive = true
    }
    
    func loadData() {
        countries.removeAll()
        for countryCode in Locale.isoRegionCodes  {
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
            if let countryName = (Locale.current as NSLocale).displayName(forKey: .identifier, value: id) {
                countries.append(.init(countryName: countryName, countryCode: countryCode))
            }
        }
        
        countries.sort { $0.countryName < $1.countryName }
    }
}

extension ViewConroller {
    
    struct CountryViewModel {
        let countryName: String
        let countryCode: String
    }
}
