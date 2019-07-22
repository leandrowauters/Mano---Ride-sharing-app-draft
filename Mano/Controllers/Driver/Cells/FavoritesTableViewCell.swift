//
//  FavoritesTableViewCell.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var favoriteName: UILabel!
    @IBOutlet weak var favoriteAddress: UILabel!
    
    @IBOutlet weak var alertView: CircularView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
