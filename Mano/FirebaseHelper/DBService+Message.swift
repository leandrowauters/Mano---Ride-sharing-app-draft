//
//  DBService+Message.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import Firebase
extension DBService {
    
    static var messagesRecieved = [Message]()
    static public func sendMessage(message: Message, completion: @escaping(Error?) -> Void) {
        let ref = firestoreDB.collection(MessageCollectionKeys.collectionKey).document()
        firestoreDB.collection(MessageCollectionKeys.collectionKey).document(ref.documentID).setData(
            [MessageCollectionKeys.senderKey : message.sender,
             MessageCollectionKeys.recipientKey : message.recipient,
             MessageCollectionKeys.senderIdKey : message.senderId,
             MessageCollectionKeys.recipientIdKey : message.recipientId,
             MessageCollectionKeys.messageKey : message.message,
             MessageCollectionKeys.messageIdKey : ref.documentID,
             MessageCollectionKeys.messageDateKey : message.messageDate,
             MessageCollectionKeys.readKey : message.read
        ]) { (error) in
            completion(error)
        }
        completion(nil)
    }
    
    static public func fetchYourMessages(completion: @escaping(Error?, [Message]?) -> Void) -> ListenerRegistration {
        return firestoreDB.collection(MessageCollectionKeys.collectionKey).whereField(MessageCollectionKeys.recipientIdKey, isEqualTo: DBService.currentManoUser.userId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                let messages = snapshot.documents.map({Message.init(dict: $0.data())})
                completion(nil, messages)
            }
        }
    }
    
    static public func fetchMessagesSent(completion: @escaping(Error?, [Message]?) -> Void) -> ListenerRegistration{
        return firestoreDB.collection(MessageCollectionKeys.collectionKey).whereField(MessageCollectionKeys.senderIdKey, isEqualTo: DBService.currentManoUser.userId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                let messages = snapshot.documents.map({Message.init(dict: $0.data())})
                completion(nil, messages)
            }
        }
    }
    
    static public func updateToMessageToRead(message: Message, completion: @escaping(Error?) -> Void) {
        firestoreDB.collection(MessageCollectionKeys.collectionKey).document(message.messageId).updateData([MessageCollectionKeys.readKey : true]) { (error) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
}
