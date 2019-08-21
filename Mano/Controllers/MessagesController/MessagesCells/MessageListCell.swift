//
//  MessageListCell.swift
//  Mano
//
//  Created by Leandro Wauters on 8/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessageListCell: UITableViewCell {

    
    @IBOutlet weak var readView: CircularViewNoBorder!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with message: Message) {
        if message.read {
            readView.isHidden = false
        }
        senderLabel.text = message.sender
        MessageLabel.text = message.message
        messageDateLabel.text = message.messageDate
    }
    
}
