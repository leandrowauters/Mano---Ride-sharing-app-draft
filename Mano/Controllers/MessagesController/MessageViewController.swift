//
//  MessageViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var listener: ListenerRegistration!
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
        fetchRecievedMessages()
    }
    

    
    private func setupTableView() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UINib(nibName: "MessageListCell", bundle: nil), forCellReuseIdentifier: "MessageListCell")
        messagesTableView.separatorStyle = .none
    }
    
    private func fetchRecievedMessages() {
        listener = DBService.fetchYourMessages { [weak self] error, messages in
            if let error = error {
                self?.showAlert(title: "Error fetching messages", message: error.localizedDescription)
            }
            if let messages = messages {
                self?.messages = messages
            }
        }
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
