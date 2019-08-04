//
//  Message.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

class Message: Codable {
    var sender: String
    var recipient: String
    var senderId: String
    var recipientId: String
    var message: String
    var messageId: String
    var messageDate: String
    var read: Bool
    
    init(sender: String, recipient: String, senderId: String, recipientId: String, message: String, messageId: String, messageDate: String, read: Bool) {
        self.sender = sender
        self.recipient = recipient
        self.senderId = senderId
        self.recipientId = recipientId
        self.message = message
        self.messageId = messageId
        self.messageDate = messageDate
        self.read = read
    }
    
    init (dict: [String: Any]) {
        self.sender = dict[MessageCollectionKeys.senderKey] as? String ?? ""
        self.recipient = dict[MessageCollectionKeys.recipientKey] as? String ?? ""
        self.senderId = dict[MessageCollectionKeys.senderIdKey] as? String ?? ""
        self.recipientId = dict[MessageCollectionKeys.recipientIdKey] as? String ?? ""
        self.message = dict[MessageCollectionKeys.messageKey] as? String ?? ""
        self.messageId = dict[MessageCollectionKeys.messageIdKey] as? String ?? ""
        self.messageDate = dict[MessageCollectionKeys.messageDateKey] as? String ?? ""
        self.read = dict[MessageCollectionKeys.readKey] as? Bool ?? false
    }
    
}
