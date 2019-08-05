//
//  MessagesListViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/4/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessagesListViewController: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    
    var messages = [Message]() {
        didSet {
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
            }
        }
    }
    
    var inbox = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchInbox()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchInbox()
    }

    private func setup() {
        messagesTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.separatorStyle = .singleLine
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    private func fetchInbox() {
        inbox = true
        DBService.fetchYourMessages { (error, inboxMessages) in
            if let error = error {
                self.showAlert(title: "Error fetching messages", message: error.localizedDescription)
            }
            if let inboxMessages = inboxMessages {
                self.messages = inboxMessages
            }
        }
    }
    @IBAction func inboxPressed(_ sender: Any) {
        fetchInbox()
    }
    @IBAction func sentPressed(_ sender: Any) {
        inbox = false
        DBService.fetchMessagesSent { (error, messagesSent) in
            if let error = error {
                self.showAlert(title: "Error fetching messages", message: error.localizedDescription)
            }
            if let messagesSent = messagesSent {
                self.messages = messagesSent
            }
        }
    }
    
}

extension MessagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = messagesTableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell else {return UITableViewCell()}
        let message = messages[indexPath.row]
        if inbox {
            if !message.read {
                cell.newMessageView.isHidden = false
            } else {
                cell.newMessageView.isHidden = true
            }
            cell.senderName.text = message.sender
        } else {
            cell.senderName.text = message.recipient
        }
        cell.messageDate.text = message.messageDate
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        DBService.updateToMessageToRead(message: message) { (error) in
            if let error = error {
                self.showAlert(title: "Error updating message", message: error.localizedDescription)
            } else {
                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: message.senderId, recipientName: message.sender, message: message)
                self.navigationController?.pushViewController(messageVC, animated: true)
            }
        }
    }
}
