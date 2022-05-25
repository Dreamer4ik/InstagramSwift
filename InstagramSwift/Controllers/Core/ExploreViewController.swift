//
//  ExploreViewController.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit

class ExploreViewController: UIViewController {

    private let searchVC = UISearchController(searchResultsController: SearchResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    

}

extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }
}

extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

