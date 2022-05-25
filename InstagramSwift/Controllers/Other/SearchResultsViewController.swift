//
//  SearchResultsViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 25.05.2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User)
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var users = [User]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [User]) {
        self.users = results
        tableView.reloadData()
        tableView.isHidden = users.isEmpty
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.searchResultsViewController(self, didSelectResultWith: users[indexPath.row])
    }
    
}
