//
//  MessageTableViewCell.swift
//  Mano
//
//  Created by Leandro Wauters on 8/4/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var newMessageView: CircularView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var messageDate: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
