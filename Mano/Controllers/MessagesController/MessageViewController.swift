//
//  MessageViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var messages = [Message]() {
        didSet{
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
            }
        }
    }
    

    @IBOutlet weak var messagesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UINib(nibName: "MessageListCell", bundle: nil), forCellReuseIdentifier: "MessageListCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as? MessageListCell else {fatalError()}
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return UITableViewCell()
    }
}
