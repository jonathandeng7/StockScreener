//
//  SearchViewController.swift
//  StockScreener
//
//  Created by Jonathan on 8/7/25.
//

import UIKit

final class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private var results: [Symbol] = []
    private var debounce: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        debounce?.invalidate()
        debounce = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("SearchVC: query='\(text)'")
            guard text.count >= 1 else {
                self.results = []
                DispatchQueue.main.async { self.tableView.reloadData() }
                return
            }
            API.searchSymbols(text) { hits in

                DispatchQueue.main.async {
                    print("SearchVC: API returned \(hits.count) hits")
                    self.results = hits
                    self.tableView.reloadData()
                }
            }

//            API.searchSymbols(text) { _ in
//                DispatchQueue.main.async {
//                    self.results = [
//                        Symbol(symbol: "AAPL", name: "Apple Inc."),
//                        Symbol(symbol: "DASH", name: "DoorDash, Inc.")
//                    ]
//                    self.tableView.reloadData()
//                }
//            }
        }
    }

    // Table
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { results.count }

    func tableView(_ tv: UITableView, cellForRowAt i: IndexPath) -> UITableViewCell {

        let reuseID = "Cell"
        let cell = tv.dequeueReusableCell(withIdentifier: reuseID) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)

        let x = results[i.row]
        cell.textLabel?.text = x.symbol
        cell.detailTextLabel?.text = x.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt i: IndexPath) {
        tv.deselectRow(at: i, animated: true)
        searchBar.resignFirstResponder()

        let ticker = results[i.row].symbol
        StockStore.shared.selectedTicker = ticker

        tabBarController?.selectedIndex = 0
    }
}
