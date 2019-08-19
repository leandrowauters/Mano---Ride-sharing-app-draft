//
//  FavoritesViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var favoritesListTableView: UITableView!
    
    
    
    var regulars = [ManoUser]() {
        didSet{
            DispatchQueue.main.async {
                self.favoritesListTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchRegulars()
    }
    
    func setup() {
        favoritesListTableView.delegate = self
        favoritesListTableView.dataSource = self
        favoritesListTableView.register(UINib(nibName: "FavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritesTableViewCell")
        favoritesListTableView.separatorStyle = .none
    }

    func fetchRegulars() {
        guard let regulars = DBService.currentManoUser.regulars else {return}
        DBService.fetchYourRegularUsers(regulars: regulars) { [weak self] error, regulars in
            if let error = error {
                self?.showAlert(title: "Error fetching regulars", message: error.localizedDescription)
            }
            if let regulars = regulars {
                self?.regulars = regulars
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regulars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesTableViewCell", for: indexPath) as? FavoritesTableViewCell else {return UITableViewCell()}
        let regular = regulars[indexPath.row]
        cell.favoriteName.text = regular.fullName
        cell.alertView.isHidden = true
        cell.favoriteAddress.text = regular.homeAdress
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
 
}
