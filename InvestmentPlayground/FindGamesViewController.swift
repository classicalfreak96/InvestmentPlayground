//
//  FindGamesController.swift
//  InvestmentPlayground
//
//  Created by Nick DesMarais on 12/2/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class FindGamesViewController: UITableViewController, UISearchBarDelegate {
    
    let db = Firestore.firestore()
    var games: [String] = []
    var filteredGames: [String] = []
    var query: String = ""
    var activeSearch: Bool = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var gamesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveGames()
        gamesTable.dataSource = self
        gamesTable.delegate = self
        searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeSearch {
            return filteredGames.count
        }
        return games.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gameCell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath) as UITableViewCell
        if activeSearch {
            gameCell.textLabel?.text = filteredGames[indexPath.row]
        }
        else {
            gameCell.textLabel?.text = games[indexPath.row]
        }
        return gameCell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredGames = []
        if searchBar.text == nil || searchBar.text! == "" {
            activeSearch = false
            searchBar.endEditing(true)
        }
        else {
            activeSearch = true
            let text = searchBar.text!
            for game in games {
                if game.lowercased().range(of: text.lowercased()) != nil {
                    filteredGames.append(game)
                }
            }
        }
        gamesTable.reloadData()
    }
    
    func retrieveGames() {
        // Help from here: https://firebase.google.com/docs/firestore/query-data/get-data
        db.collection("games").getDocuments() {  [unowned self] (querySnapshot, err) in
            if let err = err {
                print("Unable to get documents: \(err)")
            } else {
                self.games = []
                for document in querySnapshot!.documents {
                    if let title = document.data()["title"] as? String {
                        self.games.append(title)
                    }
                }
                self.gamesTable.reloadData()
            }
        }
    }
}
