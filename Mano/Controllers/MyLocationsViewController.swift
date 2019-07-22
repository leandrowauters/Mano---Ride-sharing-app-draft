//
//  MyLocationsViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MyLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var myLocationsTableView: UITableView!
    
    var myLocations = [MyLocation]() {
        didSet {
            DispatchQueue.main.async {
                self.myLocationsTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    

    func setup() {
       myLocationsTableView.register(UINib(nibName: "ManosListCell", bundle: nil), forCellReuseIdentifier: "ManosListCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return myLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManosListCell", for: indexPath) as? ManosListCell else {return UITableViewCell()}
        let myLocation = myLocations[indexPath.row]
        cell.name.text =  myLocation.locationName
        cell.address.text = myLocation.address
        cell.appointmentDateLabel.isHidden = true
        cell.riderDistance.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
