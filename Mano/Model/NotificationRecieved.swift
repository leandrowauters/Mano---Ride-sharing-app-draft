//
//  NotificationRecieved.swift
//  Mano
//
//  Created by Leandro Wauters on 7/28/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
struct NotificationRecieved: Codable {
    let title: String
    let date: Date
    let link: String
    
    @discardableResult
    static func makeNewsItem(_ notification: [String: AnyObject]) -> NotificationRecieved? {
        guard let news = notification["alert"] as? String,
            let url = notification["link_url"] as? String  else {
                return nil
        }
        
        let newsItem = NotificationRecieved(title: news, date: Date(), link: url)
        print(newsItem.title)
        
        return newsItem
    }
}
